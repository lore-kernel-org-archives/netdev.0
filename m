From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] net: ethernet: bgmac: init sequence bug
Date: Thu, 2 Feb 2017 12:47:28 +0300
Message-ID: <65fcc617-bc30-26b2-40d0-ba6a00687c33@cogentembedded.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-2-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zac Schroff <zschroff@broadcom.com>
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485988752-21030-2-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 2/2/2017 1:39 AM, Jon Mason wrote:

> From: Zac Schroff <zschroff@broadcom.com>
>
> Fix a bug in the 'bgmac' driver init sequence that blind writes for init
> sequence where it should preserve most bits other than the ones it is
> deliberately manipulating.
>
> Signed-off-by: Zac Schroff <zschroff@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: f6a95a24957 ("net: ethernet: bgmac: Add platform device support")
> ---
>  drivers/net/ethernet/broadcom/bgmac-platform.c | 10 +++++++---
>  include/linux/bcma/bcma_regs.h                 |  1 +
>  2 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
> index 6f736c1..9bbe05c 100644
> --- a/drivers/net/ethernet/broadcom/bgmac-platform.c
> +++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
> @@ -61,15 +61,19 @@ static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
>
>  static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
>  {
> -	bgmac_idm_write(bgmac, BCMA_IOCTL,
> -			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
> +	u32 regval;
> +
> +	/* Some bits of BCMA_IOCTL set by HW/ATF & should not change */
> +	regval = bgmac_idm_read(bgmac, BCMA_IOCTL) & BCMA_IOCTL_DO_NOT_MODIFY;
> +	regval |= ((flags & (~BCMA_IOCTL_DO_NOT_MODIFY)) | BCMA_IOCTL_CLK);

    The innermost parens aren't necessary. And the outermost as well.

[...]

MBR, Sergei
