From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] drivers/net: spidernet driver on Celleb
Date: Tue, 12 Dec 2006 12:24:50 +0000
Message-ID: <20061212122450.GA30466@infradead.org>
References: <200612120525.kBC5PpWC009418@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jim@jklewis.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39066 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbWLLMY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 07:24:57 -0500
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200612120525.kBC5PpWC009418@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 12, 2006 at 02:25:50PM +0900, Ishizaki Kou wrote:
> 
> Following are the changes.
> -This patch enables auto-negotiation.
> -Loading firmware is done when spidernet_open() is called.
> -And this patch adds other several small changes for Celleb. 

This should be split into three separate patches, sent as a patch
series.

> -/* outside loopback mode: ETOMOD signal dont matter, not connected */
> -#define SPIDER_NET_OPMODE_VALUE		0x00000063
> +/* ETOMOD signal is brought to PHY reset. bit2 must be 1 in Celleb */
> +#define SPIDER_NET_OPMODE_VALUE		0x00000067

Is it okay to simple change this value for the ibm blades?

> +static int is1000 = 1;

This should be in struct spider_net_card instead of a global flag.

>  	case SPIDER_NET_GTMFLLINT:
> -		if (netif_msg_intr(card) && net_ratelimit())
> -			pr_err("Spider TX RAM full\n");
> +		/* if (netif_msg_intr(card) && net_ratelimit())
> +			pr_err("Spider TX RAM full\n"); */

Either this should be kept or removed entirely.  In the latter case you
need a good description why it's removed in the patch header.

> +
> +	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
> +	                     spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);

Please make sure this doesn't overflow the 80 characters per line limit.

> +static int spider_net_init_firmware(struct spider_net_card *);

Random forward declarations in the middle of the file aren't very nice.
If you really need them put them at the beggining of the file, but it would
be even better if you moved spider_net_init_firmware further up in the
file so we wouldn't need the forward-declaration at all.

> +	if (card->phy.def->phy_id)
> +		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
> +	else
> +		pr_err("No phy is available\n");

What is this idiom about?  Is not having a phy a fatal error in which case
we should abort here, or is it tolerable in which case pr_err is too much.

> +static void spider_net_init_card(struct spider_net_card *);

Same comment above forward declarations as above.

