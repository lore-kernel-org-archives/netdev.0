From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v11 6/6] powerpc: Add flexcan device support for p1010rdb.
Date: Thu, 11 Aug 2011 12:41:34 -0500
Message-ID: <9C81E6C0-D278-40BF-8F32-445F870F845A@kernel.crashing.org>
References: <1313078831-2511-1-git-send-email-holt@sgi.com>
	<1313078831-2511-7-git-send-email-holt@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1313078831-2511-7-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


On Aug 11, 2011, at 11:07 AM, Robin Holt wrote:

> Allow the p1010 processor to select the flexcan network driver.
> 
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> Cc: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> ---
> arch/powerpc/boot/dts/p1010rdb.dts  |    8 ++++++++
> arch/powerpc/platforms/85xx/Kconfig |    2 ++
> 2 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/boot/dts/p1010rdb.dts b/arch/powerpc/boot/dts/p1010rdb.dts
> index d6c669c..df89b60 100644
> --- a/arch/powerpc/boot/dts/p1010rdb.dts
> +++ b/arch/powerpc/boot/dts/p1010rdb.dts
> @@ -171,6 +171,14 @@
> 			};
> 		};
> 
> +		can@1c000 {
> +			clock-frequency = <0x0bebc1fc>;
> +		};
> +
> +		can1: can@1d000 {
> +			clock-frequency = <0x0bebc1fc>;
> +		};
> +

set them to 0, as we expect u-boot to fill them in.

> 		usb@22000 {
> 			phy_type = "utmi";
> 		};
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> index 498534c..c4304ae 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -70,6 +70,8 @@ config MPC85xx_RDB
> config P1010_RDB
> 	bool "Freescale P1010RDB"
> 	select DEFAULT_UIMAGE
> +	select HAVE_CAN_FLEXCAN if NET && CAN
> +	select PPC_CLOCK if CAN_FLEXCAN

Can you move this to arch/powerpc/Kconfig & FSL_SOC instead.

> 	help
> 	  This option enables support for the MPC85xx RDB (P1010 RDB) board
> 
> -- 
> 1.7.2.1
