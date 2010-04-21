From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: fix linkup issue
Date: Tue, 20 Apr 2010 19:06:00 -0700 (PDT)
Message-ID: <20100420.190600.268103639.davem@davemloft.net>
References: <4BCD0424.8030501@ct.jp.nec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	divy@chelsio.com
To: h-shimamoto@ct.jp.nec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BCD0424.8030501@ct.jp.nec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Date: Tue, 20 Apr 2010 10:32:20 +0900

> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> 
> I encountered an issue that not to link up on cxgb3 fabric.
> I bisected and found that this regression was introduced by
> 0f07c4ee8c800923ae7918c231532a9256233eed.
> 
> Correct to pass phy_addr to cphy_init() at t3_xaui_direct_phy_prep().
> 
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

CXGB3 maintainers, please review.

> ---
>  drivers/net/cxgb3/ael1002.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
> index 5248f9e..35cd367 100644
> --- a/drivers/net/cxgb3/ael1002.c
> +++ b/drivers/net/cxgb3/ael1002.c
> @@ -934,7 +934,7 @@ static struct cphy_ops xaui_direct_ops = {
>  int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
>  			    int phy_addr, const struct mdio_ops *mdio_ops)
>  {
> -	cphy_init(phy, adapter, MDIO_PRTAD_NONE, &xaui_direct_ops, mdio_ops,
> +	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops,
>  		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_TP,
>  		  "10GBASE-CX4");
>  	return 0;
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
