From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Fri, 14 Aug 2009 16:36:44 -0700
Message-ID: <20090814163644.0cc8974f.akpm@linux-foundation.org>
References: <4A855DE2.2000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, davem@davemloft.net
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45647 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756232AbZHNXhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:37:16 -0400
In-Reply-To: <4A855DE2.2000907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009 14:51:46 +0200
Roel Kluin <roel.kluin@gmail.com> wrote:

> Fix the tests that check whether Frame* bits are not set
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> // vi drivers/net/wan/dscc4.c +307
> #define FrameVfr	0x80
> #define FrameRdo        0x40
> #define FrameCrc	0x20
> #define FrameRab	0x10
> 
> diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
> index 8face5d..dd3c64a 100644
> --- a/drivers/net/wan/dscc4.c
> +++ b/drivers/net/wan/dscc4.c
> @@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
>  	} else {
>  		if (skb->data[pkt_len] & FrameRdo)
>  			dev->stats.rx_fifo_errors++;
> -		else if (!(skb->data[pkt_len] | ~FrameCrc))
> +		else if (!(skb->data[pkt_len] & ~FrameCrc))
>  			dev->stats.rx_crc_errors++;

that's

	if (!(x & 0xffffffdf))

which seems peculiar.  Should it have been

	else if (skb->data[pkt_len] & FrameCrc)

or

	else if (!(skb->data[pkt_len] & FrameCrc))


> -		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
> +		else if (!(skb->data[pkt_len] & ~(FrameVfr | FrameRab)))
>  			dev->stats.rx_length_errors++;
>  		else
>  			dev->stats.rx_errors++;


