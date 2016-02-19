From: Thadeu Lima de Souza Cascardo <cascardo@debian.org>
Subject: Re: [PATCH] ehea: Drop owner assignment from platform_driver
Date: Fri, 19 Feb 2016 09:35:25 -0200
Message-ID: <20160219113524.GR4148@siri.cascardo.eti.br>
References: <20160219112219.GA2366@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160219112219.GA2366@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 19, 2016 at 04:52:19PM +0530, Amitoj Kaur Chawla wrote:
> platform_driver does not need to set an owner, it will be populated by
> the driver core.
> 
> Generated-by: scripts/coccinelle/api/platform_no_drv_owner.cocci
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea_main.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> index 2a0dc12..d4b022f 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -127,7 +127,6 @@ static const struct of_device_id ehea_device_table[] = {
>  static struct platform_driver ehea_driver = {
>  	.driver = {
>  		.name = "ehea",
> -		.owner = THIS_MODULE,
>  		.of_match_table = ehea_device_table,
>  	},
>  	.probe = ehea_probe_adapter,
> -- 
> 1.9.1
> 

NACK.

ehea does not use platform_driver_register, it uses
ibmebus_register_driver, which does not set owner.

Cascardo.
