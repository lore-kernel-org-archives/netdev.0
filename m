From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Wed, 2 Mar 2016 08:45:47 +0000
Message-ID: <SG2PR06MB103886E07FD5D8D217E91E09C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D60486.1000102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:61972 "EHLO
	relmlie1.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751144AbcCBIpx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 03:45:53 -0500
In-Reply-To: <56D60486.1000102@hartkopp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

Thanks for the review.

> On 03/01/2016 10:34 AM, Ramesh Shanmugasundaram wrote:
> > This patch adds support for the CAN FD controller found in Renesas
> > R-Car SoCs. The controller operates in CAN FD mode by default. Two
> > test modes are available and can be enabled by the
> > "rcar_canfd.testmode" module parameter. Refer to Documentation/kernel-
> parameters.txt.
> 
> (..)
> 
> > +#ifdef CONFIG_DEBUG_FS
> > +#include <linux/debugfs.h>
> > +
> > +static int rcar_canfd_showregs(struct seq_file *s, void *data) {
> > +	struct rcar_canfd_channel *priv = s->private;
> > +	u32 ch = priv->channel;
> > +	u32 rf = ch + RCANFD_RFFIFO_IDX;
> > +	u32 cf = RCANFD_CFFIFO_IDX;
> > +	u32 val, offset, i;
> > +
> > +	if (testmode)
> > +		seq_printf(s, "RCANFD : testmode = %d\n", testmode);
> > +	seq_printf(s, "RCANFD register dump: channel %u\n", ch);
> > +	seq_printf(s, "%-40s: %x\n", "g: cfg",
> > +		   rcar_canfd_read(priv, RCANFD_GCFG));
> 
> Why do you think you would need this kind of register dumps in debugfs?
> 
> This could be interesting for development purposes - but in production
> drivers this is pretty unusual and needless.

I thought it would be useful when we add more features to the driver (e.g. Gateway mode).
 
> 
> I would sugest to remove either the testmode (already suggested by Marc)
> and this register dump stuff.

OK. I'll remove both.

Thanks,
Ramesh
