From: Brandon Philips <brandon@ifup.org>
Subject: Re: [RFC] ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Tue, 15 Jul 2008 23:47:09 -0700
Message-ID: <20080716064709.GA2424@potty.ifup.org>
References: <20080715091841.GA6553@potty.ifup.org> <487D1C4C.9080103@hp.com> <20080715.152758.193724361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:4579 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbYGOWlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 18:41:24 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5499380wfd.4
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 15:41:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080715.152758.193724361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15:27 Tue 15 Jul 2008, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 15 Jul 2008 14:53:16 -0700
> 
> > Brandon Philips wrote:
> > > Introduce the speed_hi field to ethtool_cmd, using the reserved space,
> > > to expand the speed field to 2^32 Megabits/second.
> > > 
> > > Making this field expansion now gives us plenty of time to fix up the
> > > user-space pieces that use SIOCETHTOOL before hardware faster than 64
> > > Gb/s is available.
> > > 
> > > Signed-off-by: Brandon Philips <bphilips@suse.de>
> > > 
> > > ---
> > >  include/linux/ethtool.h |   17 ++++++++++++++++-
> > >  1 file changed, 16 insertions(+), 1 deletion(-)
> > > 
> > > Index: linux-2.6/include/linux/ethtool.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/linux/ethtool.h
> > > +++ linux-2.6/include/linux/ethtool.h
> > > @@ -27,9 +27,24 @@ struct ethtool_cmd {
> > >  	__u8	autoneg;	/* Enable or disable autonegotiation */
> > >  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> > >  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> > > -	__u32	reserved[4];
> > > +	__u16	speed_hi;
> > > +	__u16	reserved2;
> > > +	__u32	reserved[3];
> > >  };
> > 
> > I certainly agree with the concept of preparing for faster NICs.  Are 
> > bits in that structure sufficiently precious to go the split route, or 
> > would it be cleaner to just grab a contiguous 32 bits from the structure?
> 
> That's less space we can use to make similar expansions.
> 
> And we have to keep the existing u16 chunk there anyways, because existing
> applications are only going to provide that part.

Agreed.  Can this be queued for 2.6.27 then?

Thanks,

	Brandon
