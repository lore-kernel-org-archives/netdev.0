From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] ucc_geth: Fix sneaky merge conflict regarding
 bus_id
Date: Fri, 25 Apr 2008 01:47:34 -0400
Message-ID: <48117076.2030002@pobox.com>
References: <1208987777-17502-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46805 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682AbYDYFrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 01:47:41 -0400
In-Reply-To: <1208987777-17502-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> The patch that changed mdio_bus to a string didn't conflict strongly enough
> with the patch that added fixed PHY support to UCC.  Gather it back into
> the fold.
> 
> Fixes this error:
> ...
>  CC      drivers/net/ucc_geth.o
>  'ucc_geth_probe':
>  /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c:3935: error:
>  incompatible types in assignment
>  make[3]: *** [drivers/net/ucc_geth.o] Error 1
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 2f11254..281ce3d 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3932,7 +3932,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
>  	fixed_link = of_get_property(np, "fixed-link", NULL);
>  	if (fixed_link) {
> -		ug_info->mdio_bus = 0;
> +		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "0");
>  		ug_info->phy_address = fixed_link[0];

applied


