From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Tue, 15 Jul 2008 15:27:58 -0700 (PDT)
Message-ID: <20080715.152758.193724361.davem@davemloft.net>
References: <20080715091841.GA6553@potty.ifup.org>
	<487D1C4C.9080103@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brandon@ifup.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbYGOW17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 18:27:59 -0400
In-Reply-To: <487D1C4C.9080103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 15 Jul 2008 14:53:16 -0700

> Brandon Philips wrote:
> > Introduce the speed_hi field to ethtool_cmd, using the reserved space,
> > to expand the speed field to 2^32 Megabits/second.
> > 
> > Making this field expansion now gives us plenty of time to fix up the
> > user-space pieces that use SIOCETHTOOL before hardware faster than 64
> > Gb/s is available.
> > 
> > Signed-off-by: Brandon Philips <bphilips@suse.de>
> > 
> > ---
> >  include/linux/ethtool.h |   17 ++++++++++++++++-
> >  1 file changed, 16 insertions(+), 1 deletion(-)
> > 
> > Index: linux-2.6/include/linux/ethtool.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/ethtool.h
> > +++ linux-2.6/include/linux/ethtool.h
> > @@ -27,9 +27,24 @@ struct ethtool_cmd {
> >  	__u8	autoneg;	/* Enable or disable autonegotiation */
> >  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> >  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> > -	__u32	reserved[4];
> > +	__u16	speed_hi;
> > +	__u16	reserved2;
> > +	__u32	reserved[3];
> >  };
> 
> I certainly agree with the concept of preparing for faster NICs.  Are 
> bits in that structure sufficiently precious to go the split route, or 
> would it be cleaner to just grab a contiguous 32 bits from the structure?

That's less space we can use to make similar expansions.

And we have to keep the existing u16 chunk there anyways, because existing
applications are only going to provide that part.

