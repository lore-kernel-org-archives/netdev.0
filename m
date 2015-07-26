From: Tyler Baker <tyler.baker@linaro.org>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Sat, 25 Jul 2015 18:26:36 -0700
Message-ID: <CANMBJr5waQFD=KH9za4S5SYCOfdZu27u9nS7Frv3nCzqvkBQpA@mail.gmail.com>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	fabio.estevam@freescale.com, Shawn Guo <shawn.guo@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35290 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbbGZB0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 21:26:37 -0400
Received: by qgii95 with SMTP id i95so31335276qgi.2
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2015 18:26:36 -0700 (PDT)
In-Reply-To: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 25 July 2015 at 13:38, Andrew Lunn <andrew@lunn.ch> wrote:
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

I've tested this single patch (v6) on top of next-20150724 using the
kernelci.org bot to build and boot test[1][2] on a broad range of
platforms. With these results, I can confirm that the imx6 platforms
tested are booting fine, and that no new boot/build regressions have
been introduced when comparing these results to the next-20150724
baseline[3][4].

Tested-by: Tyler Baker <tyler.baker@linaro.org>

Cheers,

Tyler

[1] http://kernelci.org/boot/all/job/tbaker/kernel/v4.2-rc3-4216-g8c8efbc4423a/
[2] http://kernelci.org/build/tbaker/kernel/v4.2-rc3-4216-g8c8efbc4423a/
[3] http://kernelci.org/boot/all/job/next/kernel/next-20150724/
[4] http://kernelci.org/build/next/kernel/next-20150724/
