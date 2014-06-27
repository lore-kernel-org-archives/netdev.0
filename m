From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 1/3] can: m_can: add Bosch M_CAN controller support
Date: Fri, 27 Jun 2014 20:03:20 +0200
Message-ID: <53ADB1E8.1030504@hartkopp.net>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com> <1403863246-18822-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	devicetree@vger.kernel.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403863246-18822-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dong,

some general remarks from my side ...

On 27.06.2014 12:00, Dong Aisheng wrote:
>
> M_CAN also supports CANFD protocol features like data payload up to 64 bytes
> and bitrate switch at runtime, however, this patch still does not add the
> support for these features.

What is the reason for not supporting CAN FD?
The infrastructure is ready for it since Linux 3.15.

http://www.can-newsletter.org/engineering/standardization/140513_can-fd-linux-tools-and-driver-infrastructure_peak_vw/

For details see my commits for Linux 3.15.

> +  The left cell are all the number of each elements inside the message ram.
> +  Please refer to 2.4.1 Message RAM Con.guration in Bosch M_CAN user mannual
                                         ^^^
typo.

> +  for each elements definition.
> +
> +Example:
> +canfd1: canfd@020e8000 {
   ^^^^^^  ^^^^^

There's no reason to name this canfd. The fact that the controller supports
CAN FD is provided by priv->ctrlmode_supported and the CAN_CTRLMODE_FD bit.

Just write

can1: can@020e8000 {

> +	compatible = "bosch,m_can";
> +	reg = <0x020e8000 0x4000>, <0x02298000 0x4000>;
> +	reg-names = "canfd", "message_ram";
                     ^^^^^
dito.

> +	interrupts = <0 114 0x04>;
> +	clocks = <&clks IMX6SX_CLK_CANFD>;
                                   ^^^^^
dito.

> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -137,6 +137,11 @@ config CAN_XILINXCAN
>  	  Xilinx CAN driver. This driver supports both soft AXI CAN IP and
>  	  Zynq CANPS IP.
>  
> +config CAN_M_CAN
> +	tristate "Bosch M_CAN devices"
> +	---help---
> +	  Say Y here if you want to support for Bosch M_CAN controller.
> +

source "drivers/net/can/m_can/Kconfig"

>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 1697f22..69dee2c 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -17,6 +17,7 @@ obj-y				+= softing/
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_C_CAN)		+= c_can/
> +obj-$(CONFIG_CAN_M_CAN)		+= m_can.o

Please create a new m_can directory and a Kconfig in this directory analogue
to the c_can IP core approach.

>  obj-$(CONFIG_CAN_CC770)		+= cc770/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o

Thanks for your contribution,
Oliver

