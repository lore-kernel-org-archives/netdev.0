From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv4 4/9] macb: convert printk to netdev_ and friends
Date: Wed, 09 Nov 2011 05:46:08 -0800
Message-ID: <1320846368.6923.24.camel@Joe-Laptop>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
	 <1320761613-18641-5-git-send-email-jamie@jamieiles.com>
	 <1320844247.6923.18.camel@Joe-Laptop> <20111109131421.GC4253@totoro>
	 <20111109133726.GD4253@totoro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39656 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753037Ab1KINqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 08:46:09 -0500
In-Reply-To: <20111109133726.GD4253@totoro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 13:37 +0000, Jamie Iles wrote:
> OK, here's an updated patch.  Thanks again Joe!

Hi Jamie, thanks for updating, one possible thing.

> @@ -625,15 +625,12 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  #ifdef DEBUG
>  	int i;
> -	dev_dbg(&bp->pdev->dev,
> -		"start_xmit: len %u head %p data %p tail %p end %p\n",
> -		skb->len, skb->head, skb->data,
> -		skb_tail_pointer(skb), skb_end_pointer(skb));
> -	dev_dbg(&bp->pdev->dev,
> -		"data:");
> -	for (i = 0; i < 16; i++)
> -		printk(" %02x", (unsigned int)skb->data[i]);
> -	printk("\n");
> +	netdev_dbg(bp->dev,
> +		   "start_xmit: len %u head %p data %p tail %p end %p\n",
> +		   skb->len, skb->head, skb->data,
> +		   skb_tail_pointer(skb), skb_end_pointer(skb));
> +	print_hex_dump(KERN_DEBUG, "data: ", DUMP_PREFIX_OFFSET, 16, 1,
> +		       skb->data, 16, true);
>  #endif

I think there an unused variable "i" warning now
if DEBUG is #defined.
