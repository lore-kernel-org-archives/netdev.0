From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 10:24:45 -0800
Message-ID: <1393439085.407.31.camel@joe-AO722>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
	 <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: 'Alexander Aring' <alex.aring@gmail.com>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"martin.townsend@xsilon.com" <martin.townsend@xsilon.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0025.hostedemail.com ([216.40.44.25]:38874 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750813AbaBZSYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:24:48 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 16:10 +0000, David Laight wrote:
> From: Alexander Aring
[]
> > diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
[]
> > +static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
> > +{
> > +	switch (addr_mode) {
> > +	case LOWPAN_IPHC_ADDR_00:
> > +		return 16;
> > +	case LOWPAN_IPHC_ADDR_01:
> > +		return 8;
> > +	case LOWPAN_IPHC_ADDR_02:
> > +		return 2;
> > +	default:
> > +		return 0;
> > +	}
> > +}
> 
> The compiler will generate much better code if you index an array instead
> of using a switch statement.

Are you sure of that?

Perhaps the compiler would inline the assignment
anyway if addr_mode is __builtin_constant_p

gcc 4.8 here does the same thing with:

static inline unsigned char f1(unsigned char a)
{
	switch (a) {
	case 0: return 16;
	case 1: return 8;
	case 2: return 2;
	default: return 0;
	}
}

static inline unsigned char f2(unsigned char a)
{
	static const unsigned char rtns[] = { 16, 8, 2, 0 };

	return rtns[a & 3];
}
