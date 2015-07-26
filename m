From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Sat, 25 Jul 2015 21:14:12 -0300
Message-ID: <CAOMZO5DWa7rR2PZkFH-Xw9SuA-VTwHkcRYVuJejJqEHC_UcqyA@mail.gmail.com>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Tyler Baker <tyler.baker@linaro.org>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:32958 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997AbbGZAOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 20:14:14 -0400
Received: by laah7 with SMTP id h7so31476898laa.0
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2015 17:14:12 -0700 (PDT)
In-Reply-To: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Sat, Jul 25, 2015 at 5:38 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> When a switch is attached to the mdio bus, the mdio bus can be used
> while the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out.
>
> Add support for runtime PM to control this clock. Enable/disable this
> clock using runtime PM, with open()/close() and mdio read()/write()
> function triggering runtime PM operations. Since PM is optional, the
> IPG clock is enabled at probe and is no longer modified by
> fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
> guaranteed the clock is running when MDIO operations are performed.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Cc: tyler.baker@linaro.org
> Cc: fabio.estevam@freescale.com
> Cc: shawn.guo@linaro.org
> ---
>
> v5 was accepted and then reverted, because it broke imx6.  Lucas Stach
> debugged what was going wrong and provided a patch. Thanks Lucas. This
> has been squashed into v6.
>
> It would be good if this version had more testing on various platforms
> before it is accepted. If you reported a problem last time, please do
> test and send a Tested-by:

With this version I can boot via NFS on a mx6 board:

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>

Thanks
