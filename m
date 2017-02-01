From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix  NULL pointer dereference
 in switch mode
Date: Wed, 1 Feb 2017 18:30:49 +0200
Message-ID: <20170201163048.GA15402@khorivan>
References: <20170131200404.29150-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32921 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752722AbdBAQay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:30:54 -0500
Received: by mail-lf0-f47.google.com with SMTP id x1so144650563lff.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 08:30:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170131200404.29150-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 02:04:04PM -0600, Grygorii Strashko wrote:
> In switch mode on struct cpsw_slave->ndev field will be initialized with
> proper value only for the one cpsw slave port, as result
> cpsw_get_usage_count() will generate "Unable to handle kernel NULL pointer
> dereference" exception when first ethernet interface is opening
> cpsw_ndo_open(). This issue causes boot regression on AM335x EVM and
> reproducible on am57xx-evm (switch mode).
> Fix it by adding additional check for !cpsw->slaves[i].ndev in
> cpsw_get_usage_count().
> 
> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> fixes: 03fd01ad0eea ("net: ethernet: ti: cpsw: don't duplicate ndev_running")
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---

Yes, unfortunately forgot to add it. Thanks.
Reviewed-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>


>  drivers/net/ethernet/ti/cpsw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 67b7323..35a95dc 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -677,7 +677,7 @@ static int cpsw_get_usage_count(struct cpsw_common *cpsw)
>  	u32 usage_count = 0;
>  
>  	for (i = 0; i < cpsw->data.slaves; i++)
> -		if (netif_running(cpsw->slaves[i].ndev))
> +		if (cpsw->slaves[i].ndev && netif_running(cpsw->slaves[i].ndev))
>  			usage_count++;
>  
>  	return usage_count;
> -- 
> 2.10.1.dirty
> 
