From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] ARM: imx6: disable deeper idle states when FEC is active w/o HW workaround
Date: Thu, 16 Jun 2016 17:47:26 +0200
Message-ID: <4916175.LqH9s7UaP8@wuerfel>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de> <1464794983-31484-2-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Shawn Guo <shawnguo@kernel.org>, Fugang Duan <fugang.duan@nxp.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:54859 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbcFPPqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:46:32 -0400
In-Reply-To: <1464794983-31484-2-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, June 1, 2016 5:29:42 PM CEST Lucas Stach wrote:
> +/*
> + * i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from waking the
> + * CPUs when they are in wait(unclocked) state. As the hardware workaround isn't
> + * applicable to all boards, disable the deeper idle state when the workaround
> + * isn't present and the FEC is in use.
> + */
> +void imx6q_cpuidle_fec_irqs_used(void)
> +{
> +       imx6q_cpuidle_driver.states[1].disabled = true;
> +}
> +
> +void imx6q_cpuidle_fec_irqs_unused(void)
> +{
> +       imx6q_cpuidle_driver.states[1].disabled = false;
> +}
> +

These functions need to be exported, I just saw a build error in
an allmodconfig test:

ERROR: "imx6q_cpuidle_fec_irqs_unused" [drivers/net/ethernet/freescale/fec.ko] undefined!
ERROR: "imx6q_cpuidle_fec_irqs_used" [drivers/net/ethernet/freescale/fec.ko] undefined!

	Arnd
