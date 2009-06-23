From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: let SJA1000 driver depend on HAS_IOMEM
Date: Tue, 23 Jun 2009 21:26:11 +0200
Message-ID: <4A412C53.8050607@grandegger.com>
References: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:47443 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbZFWT0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 15:26:13 -0400
In-Reply-To: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Fixes this compile error on s390:
> 
> drivers/net/can/sja1000/sja1000_platform.c: In function 'sp_read_reg':
> drivers/net/can/sja1000/sja1000_platform.c:42: error: implicit declaration of function 'ioread8'
> drivers/net/can/sja1000/sja1000_platform.c: In function 'sp_write_reg':
> drivers/net/can/sja1000/sja1000_platform.c:47: error: implicit declaration of function 'iowrite8'
> drivers/net/can/sja1000/sja1000_platform.c: In function 'sp_probe':
> drivers/net/can/sja1000/sja1000_platform.c:79: error: implicit declaration of function 'ioremap_nocache'
> 
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  drivers/net/can/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/drivers/net/can/Kconfig
> ===================================================================
> --- linux-2.6.orig/drivers/net/can/Kconfig
> +++ linux-2.6/drivers/net/can/Kconfig
> @@ -36,7 +36,7 @@ config CAN_CALC_BITTIMING
>  	  If unsure, say Y.
>  
>  config CAN_SJA1000
> -	depends on CAN_DEV
> +	depends on CAN_DEV && HAS_IOMEM
>  	tristate "Philips SJA1000"
>  	---help---
>  	  Driver for the SJA1000 CAN controllers from Philips or NXP

Hm, this Kconfig entry is not directly responsible for building
sja1000_platform.o. It builds sja1000.o, which does not rely on
HAS_IOMEM. It should be added to "config CAN_SJA1000_PLATFORM" instead.
Does the patch below work for you?

Wolfgang.

---
 drivers/net/can/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next-2.6/drivers/net/can/Kconfig
===================================================================
--- net-next-2.6.orig/drivers/net/can/Kconfig
+++ net-next-2.6/drivers/net/can/Kconfig
@@ -42,7 +42,7 @@ config CAN_SJA1000
 	  Driver for the SJA1000 CAN controllers from Philips or NXP

 config CAN_SJA1000_PLATFORM
-	depends on CAN_SJA1000
+	depends on HAS_IOMEM && CAN_SJA1000
 	tristate "Generic Platform Bus based SJA1000 driver"
 	---help---
 	  This driver adds support for the SJA1000 chips connected to


