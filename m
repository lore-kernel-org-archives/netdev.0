From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Subject: Re: [PATCH v2 1/2] net: ethernet: bgmac: init sequence bug
Date: Fri, 3 Feb 2017 22:41:48 +0100
Message-ID: <8b0979e4-7202-869f-95b3-ab5d0381ed69@milecki.pl>
References: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
 <1486156133-5639-2-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Zac Schroff <zschroff@broadcom.com>
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo173.mail-out.ovh.net ([178.32.228.173]:33803 "EHLO
        mo173.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdBCWVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:21:39 -0500
Received: from player687.ha.ovh.net (b9.ovh.net [213.186.33.59])
        by mo173.mail-out.ovh.net (Postfix) with ESMTP id A78501E38F
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 22:41:55 +0100 (CET)
In-Reply-To: <1486156133-5639-2-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 10:08 PM, Jon Mason wrote:
> @@ -61,15 +60,20 @@ static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
>
>  static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
>  {
> -	bgmac_idm_write(bgmac, BCMA_IOCTL,
> -			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
> +	u32 val;
> +
> +	val = bgmac_idm_read(bgmac, BCMA_IOCTL);
> +	/* Some bits of BCMA_IOCTL set by HW/ATF and should not change */
> +	val |= flags & ~(BGMAC_AWCACHE | BGMAC_ARCACHE | BGMAC_AWUSER |
> +			 BGMAC_ARUSER);
> +	val |= BGMAC_CLK_EN;
>  	bgmac_idm_read(bgmac, BCMA_IOCTL);

This read was previously following write op most likely to flush it or
something. I don't think it makes any sense to read after read.
