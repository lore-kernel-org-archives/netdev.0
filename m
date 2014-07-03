From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Wed, 02 Jul 2014 18:28:07 -0700 (PDT)
Message-ID: <20140702.182807.1245632778216212860.davem@davemloft.net>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaGCB2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:28:08 -0400
In-Reply-To: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 29 Jun 2014 03:10:47 +0100 (BST)

> @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
>  						/* The ones required by tmd2 */
>  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
>  		if (i < 3 && ZERO)
> -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> +			printk("%d: 0x%8.8x(%#0*lx)\n",
> +			       i, leptr, 2 * (int)sizeof(long) + 2,
> +			       (long)lp->tx_buf_ptr_cpu[i]);

Please just use "%p", no casts required.
