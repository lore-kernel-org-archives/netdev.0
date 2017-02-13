From: walter harms <wharms@bfs.de>
Subject: Re: [patch net-next] net: qcom/emac: fix a sizeof() typo
Date: Mon, 13 Feb 2017 12:55:03 +0100
Message-ID: <58A19E97.6000704@bfs.de>
References: <20170213110021.GA17205@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170213110021.GA17205@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 13.02.2017 12:00, schrieb Dan Carpenter:
> We had intended to say "sizeof(u32)" but the "u" is missing.
> Fortunately, sizeof(32) is also 4, so the original code still works.
> 
> Fixes: c4e7beea2192 ("net: qcom/emac: add ethtool support for reading hardware registers")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> index 0d9945fb79be..bbe24639aa5a 100644
> --- a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> @@ -227,7 +227,7 @@ static void emac_get_regs(struct net_device *netdev,
>  
>  static int emac_get_regs_len(struct net_device *netdev)
>  {
> -	return EMAC_MAX_REG_SIZE * sizeof(32);
> +	return EMAC_MAX_REG_SIZE * sizeof(u32);
>  }
>  


We have a function where the argument is ignored and the rest is const ?

emac_ethtool_get_regs_len seems the only user. So it would be fairly easy to
move that into that function.

@maintainer:
Is there a deeper logic behind this ?


re,
 wh



>  static const struct ethtool_ops emac_ethtool_ops = {
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
