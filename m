From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Tue, 1 Mar 2016 22:07:18 +0100
Message-ID: <56D60486.1000102@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, geert+renesas@glider.be,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	mkl@pengutronix.de, wg@grandegger.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org, corbet@lwn.net
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/01/2016 10:34 AM, Ramesh Shanmugasundaram wrote:
> This patch adds support for the CAN FD controller found in Renesas R-Car
> SoCs. The controller operates in CAN FD mode by default. Two test modes
> are available and can be enabled by the "rcar_canfd.testmode" module
> parameter. Refer to Documentation/kernel-parameters.txt.

(..)

> +#ifdef CONFIG_DEBUG_FS
> +#include <linux/debugfs.h>
> +
> +static int rcar_canfd_showregs(struct seq_file *s, void *data)
> +{
> +	struct rcar_canfd_channel *priv = s->private;
> +	u32 ch = priv->channel;
> +	u32 rf = ch + RCANFD_RFFIFO_IDX;
> +	u32 cf = RCANFD_CFFIFO_IDX;
> +	u32 val, offset, i;
> +
> +	if (testmode)
> +		seq_printf(s, "RCANFD : testmode = %d\n", testmode);
> +	seq_printf(s, "RCANFD register dump: channel %u\n", ch);
> +	seq_printf(s, "%-40s: %x\n", "g: cfg",
> +		   rcar_canfd_read(priv, RCANFD_GCFG));

Why do you think you would need this kind of register dumps in debugfs?

This could be interesting for development purposes - but in production drivers
this is pretty unusual and needless.

I would sugest to remove either the testmode (already suggested by Marc) and
this register dump stuff.

Regards,
Oliver
