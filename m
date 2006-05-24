From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/4] b44: wol setup for older 4401
Date: Thu, 25 May 2006 00:13:06 +0200
Message-ID: <20060524221306.GB2863@electric-eye.fr.zoreil.com>
References: <1148481647.2976.52.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:7614 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964775AbWEXWRb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 18:17:31 -0400
To: Gary Zambrano <zambrano@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1148481647.2976.52.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gary Zambrano <zambrano@broadcom.com> :
[...]
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index b9e2462..6f4d1d4 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
[...]
> +static void b44_setup_pseudo_magicp(struct b44 *bp)
> +{
> +
> +	u32 val;
> +	int plen0, plen1, max, i, j;
> +	u8 *pwol_pattern;
> +	u8 *pwol_mask;
> +
> +	pwol_pattern = kmalloc(B44_WOL_PATTERN_SIZE, GFP_KERNEL);
> +	pwol_mask = kmalloc(B44_WOL_MASK_SIZE, GFP_KERNEL);
> +
> +	/* UDP magic packet pattern */
> +	memset(pwol_pattern, 0, B44_WOL_PATTERN_SIZE);
> +	memset(pwol_pattern + 42, 0xff, 6);	/* sync pattern */

kmalloc can fail. It should be checked.

> +	max = ETH_ALEN;
> +	for (i = 0; i < 14; ++i) {
> +		if (i == 13)
> +			max = 2;
> +		for (j = 0; j < max; ++j) {
> +			pwol_pattern[42 + 6 +
> +			(i * ETH_ALEN) + j] =
> +			bp->dev->dev_addr[j];

Indentation went strange here.

-- 
Ueimor
