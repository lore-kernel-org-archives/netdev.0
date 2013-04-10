From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [PATCH] xen-netback: use netdev_alloc_skb_ip_align
Date: Wed, 10 Apr 2013 09:41:29 -0700
Message-ID: <20130410094129.7086842d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49353 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab3DJQlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 12:41:51 -0400
Received: by mail-pb0-f53.google.com with SMTP id un15so363565pbc.26
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 09:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 10 Apr 2013 14:18:16 +0100
From: Ian Campbell <Ian.Campbell@citrix.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
Subject: Re: [PATCH] xen-netback: use netdev_alloc_skb_ip_align


On Wed, 2013-04-10 at 00:07 +0100, Stephen Hemminger wrote:
> On Tue, 9 Apr 2013 12:27:31 +0100
> Ian Campbell <Ian.Campbell@citrix.com> wrote:
> 
> > (apologies for the late reply, I've been away)
> > 
> > On Wed, 2013-03-20 at 19:21 +0000, Stephen Hemminger wrote:
> > > Use standard helper function to allocate and align received packet.
> > > Compile tested only
> > > 
> > > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > > 
> > > 
> > > --- a/drivers/net/xen-netback/netback.c	2013-03-07 18:12:52.825300956 -0800
> > > +++ b/drivers/net/xen-netback/netback.c	2013-03-20 12:09:09.052034865 -0700
> > > @@ -1357,8 +1357,8 @@ static unsigned xen_netbk_tx_build_gops(
> > >  			    ret < MAX_SKB_FRAGS) ?
> > >  			PKT_PROT_LEN : txreq.size;
> > >  
> > > -		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
> > > -				GFP_ATOMIC | __GFP_NOWARN);
> > > +		skb = __netdev_alloc_skb_ip_align(vif->dev, data_len,
> > > +						  GFP_ATOMIC | __GFP_NOWARN);
> > 
> > __netdev_alloc_skb_ip_align accounts for NET_IP_ALIGN but not
> > NET_SKB_PAD, is this aspect of the change intentional? (I'm not really
> > sure how much NET_SKB_PAD is worth in practice).
> 
> __nedev_alloc_skb_ip_align(dev, length, gfp)
>  calls __netdev_alloc_skb(dev, length + NET_IP_ALIGN, gfp)
>    calls __netdev_alloc_skb
> 
> which adds padding here:
> struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> 				   unsigned int length, gfp_t gfp_mask)
> {
> 	struct sk_buff *skb = NULL;
> 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
> 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));

Thanks for the explanation.

Acked-by: Ian Campbell <ian.campbell@citix.com>

I see this wasn't CCd to netdev -- do you want to resend or would you
like me to fwd to DaveM for you?

Ian.
