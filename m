From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Wed, 08 Jun 2016 09:52:30 -0700
Message-ID: <1465404750.25087.68.camel@perches.com>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
	 <1462843618-21914-2-git-send-email-me@tobin.cc>
	 <20160607151458.GA18008@salvia> <1465319080.25087.28.camel@perches.com>
	 <20160607173417.GA1141@salvia> <1465322550.25087.40.camel@perches.com>
	 <20160608115248.GA2603@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tcharding <me@tobin.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0203.hostedemail.com ([216.40.44.203]:51130 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751688AbcFHQwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 12:52:35 -0400
In-Reply-To: <20160608115248.GA2603@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-08 at 13:52 +0200, Pablo Neira Ayuso wrote:
> On Tue, Jun 07, 2016 at 11:02:30AM -0700, Joe Perches wrote:
> > On Tue, 2016-06-07 at 19:34 +0200, Pablo Neira Ayuso wrote:
> > > On Tue, Jun 07, 2016 at 10:04:40AM -0700, Joe Perches wrote:
> > > > One more question, is this chunk below correct from
> > > > coding style point of view?
> > > =A0=A0=A0=A0=A0=A0=A0=A0if (info->bitmask & EBT_STP_ROOTADDR) {
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0verdict =3D 0;
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i <=
 6; i++)
> > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
> > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2 + i] ^ c->root_addr[i]) &
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
> > >=20
> > > I think the previous line is fine.
> > "2+i" or "2 + i", either is OK.
> > Multiple line statement alignment doesn't
> > matter much.
> Sorry, I was actually refering to:
[]

Hi again Pablo.

No worries. =A0I hoped the "doesn't matter much" was clear enough.

There are many different multiple line statement alignment
styles in the kernel.

Alignment to open parenthesis is one of them, and I think it's
reasonable to standardize on that.

=46or multiple line statements without parentheses for alignment,
I think there isn't one style that's much better than another.

I slightly prefer the original alignment above myself.

> > Perhaps it's better to add a function for this though.
> I like this function idea :).

Maybe something like this is clearer:

static bool ebt_test_addr(const uint8_t *root, const char *addr,
			=A0 const char *mask)
{
	int i;

	for (i =3D 0; i < ETH_ALEN; i++) {
		if ((root[2 + i] ^ addr[i]) & mask[i])
			return true;
	}

	return false;
}

Maybe the call should add the + 2 to the first argument
instead of using + 2 in the loop.
