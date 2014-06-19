From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v7 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Thu, 19 Jun 2014 16:46:23 +0800
Message-ID: <CACVXFVNx4gCGuE9=4Z8iaY+hhy6b3db-vAQuKFoA4spY4s_QmQ@mail.gmail.com>
References: <1403140634-27104-1-git-send-email-isubramanian@apm.com>
	<1403140634-27104-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jon Masters <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches-qTEPVZfXA3Y@public.gmane.org,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403140634-27104-5-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 19, 2014 at 9:17 AM, Iyappan Subramanian
<isubramanian-qTEPVZfXA3Y@public.gmane.org> wrote:
> This patch adds network driver for APM X-Gene SoC ethernet.
>
> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
> ---
>  drivers/net/ethernet/Kconfig                       |   1 +
>  drivers/net/ethernet/Makefile                      |   1 +
>  drivers/net/ethernet/apm/Kconfig                   |   1 +
>  drivers/net/ethernet/apm/Makefile                  |   5 +
>  drivers/net/ethernet/apm/xgene/Kconfig             |   9 +
>  drivers/net/ethernet/apm/xgene/Makefile            |   6 +
>  .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 125 +++
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 848 +++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     | 394 +++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 939 +++++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h   | 109 +++
>  11 files changed, 2438 insertions(+)
>  create mode 100644 drivers/net/ethernet/apm/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
>
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index edb7186..dc7406c 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -24,6 +24,7 @@ source "drivers/net/ethernet/allwinner/Kconfig"
>  source "drivers/net/ethernet/alteon/Kconfig"
>  source "drivers/net/ethernet/altera/Kconfig"
>  source "drivers/net/ethernet/amd/Kconfig"
> +source "drivers/net/ethernet/apm/Kconfig"
>  source "drivers/net/ethernet/apple/Kconfig"
>  source "drivers/net/ethernet/arc/Kconfig"
>  source "drivers/net/ethernet/atheros/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 58de333..224a018 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
>  obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
>  obj-$(CONFIG_ALTERA_TSE) += altera/
>  obj-$(CONFIG_NET_VENDOR_AMD) += amd/
> +obj-$(CONFIG_NET_XGENE) += apm/
>  obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
>  obj-$(CONFIG_NET_VENDOR_ARC) += arc/
>  obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
> diff --git a/drivers/net/ethernet/apm/Kconfig b/drivers/net/ethernet/apm/Kconfig
> new file mode 100644
> index 0000000..ec63d70
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/Kconfig
> @@ -0,0 +1 @@
> +source "drivers/net/ethernet/apm/xgene/Kconfig"
> diff --git a/drivers/net/ethernet/apm/Makefile b/drivers/net/ethernet/apm/Makefile
> new file mode 100644
> index 0000000..65ce32a
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for APM X-GENE Ethernet driver.
> +#
> +
> +obj-$(CONFIG_NET_XGENE) += xgene/
> diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
> new file mode 100644
> index 0000000..616dff6
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/Kconfig
> @@ -0,0 +1,9 @@
> +config NET_XGENE
> +       tristate "APM X-Gene SoC Ethernet Driver"
> +       select PHYLIB
> +       help
> +         This is the Ethernet driver for the on-chip ethernet interface on the
> +         APM X-Gene SoC.
> +
> +         To compile this driver as a module, choose M here. This module will
> +         be called xgene_enet.
> diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
> new file mode 100644
> index 0000000..c643e8a
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/Makefile
> @@ -0,0 +1,6 @@
> +#
> +# Makefile for APM X-Gene Ethernet Driver.
> +#
> +
> +xgene-enet-objs := xgene_enet_hw.o xgene_enet_main.o xgene_enet_ethtool.o
> +obj-$(CONFIG_NET_XGENE) += xgene-enet.o
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
> new file mode 100644
> index 0000000..bac097e
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
> @@ -0,0 +1,125 @@
> +/* Applied Micro X-Gene SoC Ethernet Driver
> + *
> + * Copyright (c) 2014, Applied Micro Circuits Corporation
> + * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/ethtool.h>
> +#include <xgene_enet_main.h>

drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c:21:29: fatal
error: xgene_enet_main.h: No such file or directory
 #include <xgene_enet_main.h>
                             ^
compilation terminated.

Thanks,
--
Ming Lei



-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
