From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ARC vmac ethernet driver.
Date: Tue, 19 Oct 2010 06:53:17 -0700 (PDT)
Message-ID: <20101019.065317.246538050.davem@davemloft.net>
References: <1287129254-18078-1-git-send-email-andreas.fenkart@streamunlimited.com>
	<1287129254-18078-2-git-send-email-andreas.fenkart@streamunlimited.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.fenkart@streamunlimited.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750984Ab0JSNwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 09:52:55 -0400
In-Reply-To: <1287129254-18078-2-git-send-email-andreas.fenkart@streamunlimited.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Date: Fri, 15 Oct 2010 09:54:14 +0200

> +
> +#undef DEBUG
> +

Please remove this.

> +#if 0
> +	/* FIXME: what is it used for? */
> +	platform_set_drvdata(ap->dev, ap->mii_bus);
> +#endif

Resolve this one way or another, either figure out what it's used
for and keep it or remove it if it is unnedeed.

> +		/* IP header Alignment (14 byte Ethernet header) */
> +		skb_reserve(skb, 2);

Use "NET_IP_ALIGN", not "2", different architectures want to
use different values.

> +	skb_reserve(merge_skb, 2);

Same thing here, use NET_IP_ALIGN.

> +/* arcvmac private data structures */
> +struct vmac_buffer_desc {
> +	unsigned int info;
> +	dma_addr_t data;
> +};

If this is the actual descriptor used by the hardware you
cannot define it this way.

dma_addr_t is a variable type, on some platforms it is a
"u32", on others it is a "u64" but you cannot assume one
way or another.

Also, are these values big or little endian?  You must use
the appropriate endian types such as __be32 et al. and then
access the members using the proper conversion functions.
