From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH] sh_eth: add R8A77781 support
Date: Sun, 28 Apr 2013 22:33:04 +0200
Message-ID: <1729391.fxbIzSoxUb@avalon>
References: <201304280044.25139.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201304280044.25139.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thank you for the patch.

On Sunday 28 April 2013 00:44:24 Sergei Shtylyov wrote:
> Add support for another ARM member of the R-Car family, R-Car M1A, also
> known as R8A77781 -- it will share the code with previously added R8A77790.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> This patch is for the 'net-next.git' repository but it may not be fit for
> immediate applying as R-Car M1A support will only be merged in 3.10-rc1...
> 
>  drivers/net/ethernet/renesas/Kconfig  |    3 ++-
>  drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> Index: net-next/drivers/net/ethernet/renesas/Kconfig
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/Kconfig
> +++ net-next/drivers/net/ethernet/renesas/Kconfig
> @@ -8,7 +8,8 @@ config SH_ETH
>  		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
>  		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
>  		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7734 || \
> -		 CPU_SUBTYPE_SH7757 || ARCH_R8A7740 || ARCH_R8A7779)
> +		 CPU_SUBTYPE_SH7757 || ARCH_R8A7740 || \
> +		 ARCH_R8A7778 || ARCH_R8A7779)
>  	select CRC32
>  	select NET_CORE
>  	select MII
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -342,7 +342,7 @@ static void sh_eth_select_mii(struct net
>  #endif
> 
>  /* There is CPU dependent code */
> -#if defined(CONFIG_ARCH_R8A7779)
> +#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
>  #define SH_ETH_RESET_DEFAULT	1
>  static void sh_eth_set_duplex(struct net_device *ndev)
>  {
> @@ -370,7 +370,7 @@ static void sh_eth_set_rate(struct net_d
>  	}
>  }
> 
> -/* R8A7779 */
> +/* R8A7778/9 */
>  static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>  	.set_duplex	= sh_eth_set_duplex,
>  	.set_rate	= sh_eth_set_rate,

I was wondering if someone is working (or was planning to work in the near 
future) in getting rid of that #ifdef mess and add proper support for 
multiplatform kernels to the sh-eth driver ?

The patch looks good to me though, the above isn't a reason to delay it.

-- 
Regards,

Laurent Pinchart

