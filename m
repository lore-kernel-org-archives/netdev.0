From: Ulrich Hecht <ulrich.hecht@gmail.com>
Subject: Re: [RESEND PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Thu, 2 Jun 2016 18:01:59 +0200
Message-ID: <CAO3366wP+tBaGbrMceupcJu0agW5Euo3NBNwijNCmpM1XcDGmQ@mail.gmail.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
	<1464860702-46087-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
	<1464860702-46087-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	chris.paterson2@renesas.com, Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1464860702-46087-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for your patch.

On Thu, Jun 2, 2016 at 11:45 AM, Ramesh Shanmugasundaram
<ramesh.shanmugasundaram@bp.renesas.com> wrote:
[...]
> diff --git a/drivers/net/can/rcar/rcar_canfd.c b/drivers/net/can/rcar/rcar_canfd.c
> new file mode 100644
> index 0000000..e198732
> --- /dev/null
> +++ b/drivers/net/can/rcar/rcar_canfd.c
> @@ -0,0 +1,1624 @@
> +/* Renesas R-Car CAN FD device driver
> + *
> + * Copyright (C) 2015 Renesas Electronics Corp.
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.
> + */
> +
> +/* The R-Car CAN FD controller can operate in either one of the below two modes
> + *  - CAN FD only mode
> + *  - Classical CAN (CAN 2.0) only mode
> + *
> + * This driver puts the controller in CAN FD only mode by default. In this
> + * mode, the controller acts as a CAN FD node that can also interoperate with
> + * CAN 2.0 nodes.
> + *
> + * As of now, this driver does not support the Classical CAN (CAN 2.0) mode,
> + * which is handled by a different register map compared to CAN FD only mode.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/moduleparam.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/can/led.h>
> +#include <linux/can/dev.h>
> +#include <linux/clk.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/bitmap.h>
> +#include <linux/bitops.h>
> +#include <linux/iopoll.h>
> +
> +#define RCANFD_DRV_NAME                        "rcar_canfd"
> +
> +#define RCANFD_FIFO_DEPTH              8       /* Tx FIFO depth */
> +#define RCANFD_NAPI_WEIGHT             8       /* Rx poll quota */
> +
> +#define RCANFD_NUM_CHANNELS            2       /* Two channels max */
> +#define RCANFD_CHANNELS_MASK           BIT((RCANFD_NUM_CHANNELS) - 1)
> +
> +/* Rx FIFO is a global resource of the controller. There are 8 such FIFOs
> + * available. Each channel gets a dedicated Rx FIFO (i.e.) the channel
> + * number is added to RFFIFO index.
> + */
> +#define RCANFD_RFFIFO_IDX              0
> +
> +/* Tx/Rx or Common FIFO is a per channel resource. Each channel has 3 Common
> + * FIFOs dedicated to them. Use the first (index 0) FIFO out of the 3 for Tx.
> + */
> +#define RCANFD_CFFIFO_IDX              0
> +
> +/* Global register bits */
> +#define RCANFD_GINTF_CANFD             BIT(0)
> +
> +#define RCANFD_GCFG_TPRI               BIT(0)
> +#define RCANFD_GCFG_DCE                        BIT(1)
> +#define RCANFD_GCFG_DCS                        BIT(4)
> +#define RCANFD_GCFG_CMPOC              BIT(5)

What reference are the register layouts based on? This bit, for
instance, is marked reserved in R-Car-Gen3-rev0.51e.pdf, and many are
named differently.

CU
Uli
