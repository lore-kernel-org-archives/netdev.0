From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v4] add the driver for Analog Devices Blackfin on-chip
	CAN controllers
Date: Fri, 11 Dec 2009 11:00:31 +0100
Message-ID: <4B22183F.2070806@grandegger.com>
References: <1260524788-13103-1-git-send-email-21cnbao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, "H.J. Oertel" <oe-pJ9TYRvN+WE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1260524788-13103-1-git-send-email-21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Barry Song wrote:
> Signed-off-by: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: H.J. Oertel <oe-pJ9TYRvN+WE@public.gmane.org>
> ---
>  -v4:
>  1. request and release interrupts in open/close instead of in module load/unload
>  2. use bfin_read16/write16 instead of common readw/writew
>  3. fix "line over 80 characters" checkpatch warning
>  4. fix other coding style issues required by Wolfgang Grandegger

David, here is my

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O63ddJNmlsFzeA@public.gmane.org>

for this driver. There is just some minor issue with the copyright
below. IIRC, the merge window is still open. It would be nice if this
driver gets accepted for 2.6.33 already. Thanks.

>  drivers/net/can/Kconfig    |    9 +
>  drivers/net/can/Makefile   |    1 +
>  drivers/net/can/bfin_can.c |  783 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 793 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/bfin_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index bb803fa..8c485aa 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -54,6 +54,15 @@ config CAN_MCP251X
>  	---help---
>  	  Driver for the Microchip MCP251x SPI CAN controllers.
>  
> +config CAN_BFIN
> +	depends on CAN_DEV && (BF534 || BF536 || BF537 || BF538 || BF539 || BF54x)
> +	tristate "Analog Devices Blackfin on-chip CAN"
> +	---help---
> +	  Driver for the Analog Devices Blackfin on-chip CAN controllers
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called bfin_can.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 56899fe..7a702f2 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -14,5 +14,6 @@ obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
> +obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> new file mode 100644
> index 0000000..c7fc1de
> --- /dev/null
> +++ b/drivers/net/can/bfin_can.c
> @@ -0,0 +1,783 @@
> +/*
> + * Blackfin On-Chip CAN Driver
> + *
> + * Copyright 2004-2009 Analog Devices Inc.
> + *
> + * Enter bugs at http://blackfin.uclinux.org/
> + *
> + * Licensed under the GPL-2 or later.
> + */

David, is this a legal (acceptable) copyright note or is the usual
"GPL-2 or later" text required.

Barry, thanks for your contribution.

Wolfgang.
