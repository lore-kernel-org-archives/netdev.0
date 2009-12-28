From: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Mon, 28 Dec 2009 22:31:14 +0100
Message-ID: <20091228213114.GA24285@zoreil.com>
References: <20091228194834.GA18422@hmsreliant.think-freely.org> <20091228195053.GB18422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nhorman@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pulsar.zoreil.com ([83.167.33.49]:51523 "EHLO pulsar.zoreil.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbZL1VbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 16:31:20 -0500
Content-Disposition: inline
In-Reply-To: <20091228195053.GB18422@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I'm back)

The Mon, Dec 28, 2009 at 02:50:53PM -0500, Neil Horman wrote :
[...]
> frames were received on NIC's supported by this driver.  This was mentioned in a
> security conference recently:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html

Is there a paper ?

> It seems that if we can't enable frame size filtering, then, as Eric correctly
> noticed, we can find ourselves DMA-ing too much data to a buffer, causing
> corruption.  As a result is seems that we are forced to allocate a frame which
> is ready to handle a maximally sized receive.

Either that or the switch does not allow jumbo frames.

> I've not tested the below patch at all, and clearly it stinks to have to do.
> But I thought it would be worth posting to solicit comments on it.
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 60f96c4..42e3b22 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -3972,7 +3973,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
>  
>  	pad = align ? align : NET_IP_ALIGN;
>  
> -	skb = netdev_alloc_skb(dev, rx_buf_sz + pad);
> +	skb = netdev_alloc_skb(dev, 16383 + pad);

I doubt that we will be able to allocate that much memory reliably for long.

I'd rather go for static buffers + copy (+ src mac address of our new friend).

Is it enough if I write it in a pair of evening ?

-- 
Ueimor
