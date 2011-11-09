From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv4 4/9] macb: convert printk to netdev_ and friends
Date: Wed, 9 Nov 2011 13:55:46 +0000
Message-ID: <20111109135546.GE4253@totoro>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
 <1320761613-18641-5-git-send-email-jamie@jamieiles.com>
 <1320844247.6923.18.camel@Joe-Laptop>
 <20111109131421.GC4253@totoro>
 <20111109133726.GD4253@totoro>
 <1320846368.6923.24.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	arnd@arndb.de
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44493 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab1KINzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 08:55:50 -0500
Received: by wyh15 with SMTP id 15so1616833wyh.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 05:55:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1320846368.6923.24.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 05:46:08AM -0800, Joe Perches wrote:
> On Wed, 2011-11-09 at 13:37 +0000, Jamie Iles wrote:
> > OK, here's an updated patch.  Thanks again Joe!
> 
> Hi Jamie, thanks for updating, one possible thing.
> 
> > @@ -625,15 +625,12 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  
> >  #ifdef DEBUG
> >  	int i;
> > -	dev_dbg(&bp->pdev->dev,
> > -		"start_xmit: len %u head %p data %p tail %p end %p\n",
> > -		skb->len, skb->head, skb->data,
> > -		skb_tail_pointer(skb), skb_end_pointer(skb));
> > -	dev_dbg(&bp->pdev->dev,
> > -		"data:");
> > -	for (i = 0; i < 16; i++)
> > -		printk(" %02x", (unsigned int)skb->data[i]);
> > -	printk("\n");
> > +	netdev_dbg(bp->dev,
> > +		   "start_xmit: len %u head %p data %p tail %p end %p\n",
> > +		   skb->len, skb->head, skb->data,
> > +		   skb_tail_pointer(skb), skb_end_pointer(skb));
> > +	print_hex_dump(KERN_DEBUG, "data: ", DUMP_PREFIX_OFFSET, 16, 1,
> > +		       skb->data, 16, true);
> >  #endif
> 
> I think there an unused variable "i" warning now
> if DEBUG is #defined.

Good eyes!  I've fixed that but won't repost it.

Jamie
