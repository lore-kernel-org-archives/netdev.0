From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/2] [PATCH] ne.c fix rmmod, platform driver
 improvements
Date: Sun, 14 Sep 2008 00:13:00 +0900 (JST)
Message-ID: <20080914.001300.15242170.anemo@mba.ocn.ne.jp>
References: <20080909025821.GA25019@spacedout.fries.net>
	<20080911.225503.59032738.anemo@mba.ocn.ne.jp>
	<20080913144457.GE28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: david@fries.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:52104 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbYIMPMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 11:12:52 -0400
In-Reply-To: <20080913144457.GE28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Sep 2008 09:44:57 -0500, David Fries <david@fries.net> wrote:
> I reformatted your patch and added a comment.  Does this work for you?
> 
> diff --git a/drivers/net/ne.c b/drivers/net/ne.c
...
>  	/* Update with any values found by probing. */
> -	io[this_dev] = dev->base_addr;
> -	irq[this_dev] = dev->irq;
> +	if (0 <= this_dev && this_dev < MAX_NE_CARDS) {
> +		io[this_dev] = dev->base_addr;
> +		irq[this_dev] = dev->irq;
> +	}
>  	return 0;
>  }

For now rbtx49xx ne platform devices use -1 for pdev->id, but it may
change.  Please don't assume it.

---
Atsushi Nemoto
