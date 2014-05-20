From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: Remove unbalanced clk_disable call
Date: Tue, 20 May 2014 12:08:36 +0200
Message-ID: <537B29A4.1010100@st.com>
References: <1400578698-6407-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chen-Yu Tsai <wens@csie.org>, <netdev@vger.kernel.org>
To: Hans de Goede <hdegoede@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:34107 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750771AbaETKI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 06:08:59 -0400
In-Reply-To: <1400578698-6407-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/20/2014 11:38 AM, Hans de Goede wrote:
> The stmmac_open call was calling clk_disable_unprepare on phy init
> failure, but it never calls clk_prepare_enable, this causes
> a WARN_ON in the clk framework to trigger if for some reason phy init
> fails.
>
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index d940034..0f4841d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1704,7 +1704,7 @@ static int stmmac_open(struct net_device *dev)
>   		if (ret) {
>   			pr_err("%s: Cannot attach to PHY (error: %d)\n",
>   			       __func__, ret);
> -			goto phy_error;
> +			return ret;
>   		}
>   	}
>
> @@ -1779,8 +1779,6 @@ init_error:
>   dma_desc_error:
>   	if (priv->phydev)
>   		phy_disconnect(priv->phydev);
> -phy_error:
> -	clk_disable_unprepare(priv->stmmac_clk);
>
>   	return ret;
>   }
>
