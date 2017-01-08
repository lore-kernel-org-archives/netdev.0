From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove dual check from common
 res usage function
Date: Sun, 8 Jan 2017 18:20:49 +0200
Message-ID: <20170108162047.GA13599@khorivan>
References: <1483883787-13503-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1483883787-13503-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please ignore it, I've included it in new series

On Sun, Jan 08, 2017 at 03:56:27PM +0200, Ivan Khoronzhuk wrote:
> Common res usage is possible only in case an interface is
> running. In case of not dual emac here can be only one interface,
> so while ndo_open and switch mode, only one interface can be opened,
> thus if open is called no any interface is running ... and no common
> res are used. So remove check on dual emac, it will simplify
> code/understanding and will match the name it's called.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
> 
> Based on linux-next/master
> 
>  drivers/net/ethernet/ti/cpsw.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index b203143..91684f1 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1235,9 +1235,6 @@ static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
>  	u32 i;
>  	u32 usage_count = 0;
>  
> -	if (!cpsw->data.dual_emac)
> -		return 0;
> -
>  	for (i = 0; i < cpsw->data.slaves; i++)
>  		if (cpsw->slaves[i].open_stat)
>  			usage_count++;
> -- 
> 2.7.4
> 
