From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH RFC 10/10] mlx4_en: Makefile and Kconfig
Date: Mon, 14 Jul 2008 23:27:26 -0400
Message-ID: <20080714232726.7719a2ab.billfink@mindspring.com>
References: <487B65CE.4060509@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:56699 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226AbYGOD1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:27:34 -0400
In-Reply-To: <487B65CE.4060509@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jul 2008, Yevgeny Petrilin wrote:

> Changed Makefile and Kconfig files to enable mlx4_en compilation.
> 
> Signed-off-by: Liran Liss <liranl@mellanox.co.il>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/Kconfig       |    9 +++++++++
>  drivers/net/mlx4/Makefile |    5 +++++
>  2 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f4182cf..4aaa7e9 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2549,6 +2549,15 @@ config PASEMI_MAC
>  	  This driver supports the on-chip 1/10Gbit Ethernet controller on
>  	  PA Semi's PWRficient line of chips.
> 
> +config MLX4_EN
> +	tristate "Mellanox Technologies 10Gbit Ethernet support"
> +	depends on PCI
> +	select MLX4_CORE
> +	select INET_LRO
> +	help
> +	  This driver supports Mellanox Technollogies ConnectX Ethernet
> +	  devices.
> +
>  config MLX4_CORE
>  	tristate
>  	depends on PCI

To prevent certain build failures, when you "select INET_LRO" you also
need to add a depends on INET, so the above "depends on PCI" needs to
be changed to:

	depends on PCI && INET

						-Bill
