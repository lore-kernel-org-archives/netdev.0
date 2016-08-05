From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 08/11] net/fsl: use of_property_read_bool
Date: Fri, 5 Aug 2016 14:35:26 +0300
Message-ID: <ceb47a0e-5759-486c-68d9-3feb9faf9e7a@cogentembedded.com>
References: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr>
 <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/5/2016 11:56 AM, Julia Lawall wrote:

> Use of_property_read_bool to check for the existence of a property.
>
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> expression e1,e2;
> statement S2,S1;
> @@
> -       if (of_get_property(e1,e2,NULL))
> +       if (of_property_read_bool(e1,e2))
>         S1 else S2
> // </smpl>
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
>  drivers/net/ethernet/freescale/xgmac_mdio.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> index 7b8fe86..a77ba98 100644
> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> @@ -271,8 +271,7 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
>  		goto err_ioremap;
>  	}
>
> -	if (of_get_property(pdev->dev.of_node,
> -			    "little-endian", NULL))
> +	if (of_property_read_bool(pdev->dev.of_node, "little-endian"))
>  		priv->is_little_endian = true;
>  	else
>  		priv->is_little_endian = false;

    priv->is_little_endian = of_property_read_bool(pdev->dev.of_node,
						  "little-endian"));

MBR, Sergei
