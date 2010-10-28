From: Alexander Wigen <alex@wigen.net>
Subject: Re: [PATCH] via-velocity: Codestyle fixes
Date: Thu, 28 Oct 2010 15:02:47 +1000
Message-ID: <201010281502.47977.alex@wigen.net>
References: <1288237684-30783-1-git-send-email-alex@wigen.net> <1288239318.1836.7.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asav3.lyse.net ([81.167.37.131]:51617 "EHLO asav3.lyse.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab0J1FfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 01:35:11 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by asav3.lyse.net (Postfix) with ESMTP id 83B7884054
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 07:02:47 +0200 (CEST)
Received: from wigen.net (2.84-234-148.customer.lyse.net [84.234.148.2])
	by asav3.lyse.net (Postfix) with SMTP id ACC6284011
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 07:02:46 +0200 (CEST)
In-Reply-To: <1288239318.1836.7.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

Thanks for that very quick review, this is my first kernel patch.

On Thu, 28 Oct 2010, you wrote:
> On Thu, 2010-10-28 at 13:48 +1000, alex@wigen.net wrote:
> > From: Alexander Wigen <alex@wigen.net>
> > @@ -1542,7 +1542,7 @@ static int velocity_alloc_rx_buf(struct
> > velocity_info *vptr, int idx)
> > 
> >  	 *	Fill in the descriptor to match
> >  	 */
> > 
> > -	*((u32 *) & (rd->rdesc0)) = 0;
> > +	*((u32 *) &(rd->rdesc0)) = 0;
> 
> I think this style change isn't really that good.
> rdesc0 is:
> 
> struct rdesc0 {
> 	__le16 RSR;		/* Receive status */
> 	__le16 len;		/* bits 0--13; bit 15 - owner */
> };
> 
> I think it more sensible to either set the fields
> in the struct to 0 or to memset the struct to 0.

Not sure what is best so I reverted the change.

> > @@ -1681,7 +1681,7 @@ static int velocity_init_td_ring(struct
> > velocity_info *vptr)
> > 
> >  static void velocity_free_dma_rings(struct velocity_info *vptr)
> >  {
> >  
> >  	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
> > 
> > -		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
> > +		vptr->options.numtx * sizeof(struct tx_desc) *vptr->tx.numq;
> 
> If checkpatch warns about this, it's wrong.

It does produce a error acctually, but I have reverted the change:

drivers/net/via-velocity.c:1684: ERROR: space prohibited after that '*' 
(ctx:WxW)


> 
> > @@ -2477,24 +2477,24 @@ static struct net_device_stats
> > *velocity_get_stats(struct net_device *dev)
> > 
> >  	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
> >  	dev->stats.rx_length_errors =
> >  	vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
> > 
> > -//  unsigned long   rx_dropped;     /* no space in linux buffers    */
> > +/*  unsigned long   rx_dropped;     /* no space in linux buffers    */
> 
> why not just remove all these commented-out lines?

Done.

> > @@ -2957,7 +2957,7 @@ static int velocity_set_wol(struct velocity_info
> > *vptr)
> > 
> >  		memcpy(arp->ar_tip, vptr->ip_addr, 4);
> >  		
> >  		crc = wol_calc_crc((sizeof(struct arp_packet) + 7) / 8, buf,
> > 
> > -				(u8 *) & mask_pattern[0][0]);
> > +				(u8 *) &mask_pattern[0][0]);
> 
> perhaps just (u8 *)mask_pattern?
> 
> > @@ -3454,7 +3453,7 @@ static const struct ethtool_ops
> > velocity_ethtool_ops = {
> > 
> >  	.set_wol	=	velocity_ethtool_set_wol,
> >  	.get_msglevel	=	velocity_get_msglevel,
> >  	.set_msglevel	=	velocity_set_msglevel,
> > 
> > -	.set_sg 	=	ethtool_op_set_sg,
> > +	.set_sg	=	ethtool_op_set_sg,
> 
> bad alignment?

Sorry, wrong editor tab width.

Cheers,
Alexander Wigen
