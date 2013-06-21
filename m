From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next,v5,2/3] bridge: only expire the mdb entry when query
 is received
Date: Fri, 21 Jun 2013 15:34:11 +0800
Message-ID: <20130621073411.GA24488@gondor.apana.org.au>
References: <1369209176-6841-2-git-send-email-amwang@redhat.com>
 <20130618120338.GA9063@Linus-Debian>
 <20130619044438.GA8174@gondor.apana.org.au>
 <1371799901.32026.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55424 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161061Ab3FUHeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 03:34:20 -0400
Content-Disposition: inline
In-Reply-To: <1371799901.32026.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 03:31:41PM +0800, Cong Wang wrote:
> On Wed, 2013-06-19 at 12:44 +0800, Herbert Xu wrote:
> > On Tue, Jun 18, 2013 at 02:03:38PM +0200, Linus L=FCssing wrote:
> > > Hi Amerigo,
> > >=20
> > > I just tested these three patches on top of 3.10-rc6 (thanks for
> > > looking into these issues so far!) but unfortunately I'm still
> > > having problems if there is no querier on the link:
> > >=20
> > > We will never discover a multicast listener which sends its
> > > startup MLD reports before being attached to the bridge port.
> > >=20
> > > I had reported that issue two months ago to Herbert's patch which
> > > changed the querier default [1].
> > >=20
> > > I guess in such a scenario where neither our querier is activated
> > > nor could we detect any querier, then the only safe thing we can
> > > do is to disable the bridge multicast snooping, isn't it?
> >=20
> > If we have seen no queries then we should simply flood.  The fact
> > that we don't currently is a bug.
>=20
> Something like this?

Close, ideally we should allow for at least one timeout interval
after seeing the first query.

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
