From: Marek Vasut <marex@denx.de>
Subject: Re: FEC performance degradation with certain packet sizes
Date: Tue, 21 Jan 2014 18:49:10 +0100
Message-ID: <201401211849.10113.marex@denx.de>
References: <528F50AE.3030804@digi.com> <52B45BD2.2060306@digi.com> <45804b55ce704164bc054d4275801153@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hector Palacios <hector.palacios@digi.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:56648 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbaAURtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 12:49:14 -0500
In-Reply-To: <45804b55ce704164bc054d4275801153@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, December 23, 2013 at 03:52:20 AM, fugang.duan@freescale.com wrote:
> From: Hector Palacios <hector.palacios@digi.com>
> Sent: Friday, December 20, 2013 11:02 PM
> 
> >To: Duan Fugang-B38611; Marek Vasut; netdev@vger.kernel.org
> >Cc: Estevam Fabio-R49496; shawn.guo@linaro.org; l.stach@pengutronix.de; Li
> >Frank-B20596; bhutchings@solarflare.com; davem@davemloft.net
> >Subject: Re: FEC performance degradation with certain packet sizes
> >
> >Dear Andy,
> >
> >On 12/20/2013 04:35 AM, fugang.duan@freescale.com wrote:
> >> [...]
> >> 
> >> I can reproduce the issue on imx6q/dl platform with freescale internal
> >> kernel
> >
> >tree.
> >
> >> This issue must be related to cpufreq, when set scaling_governor to
> >
> >performance:
> >> echo performance >
> >> /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> >> 
> >> And then do NPtcp test, the result as below:
> >>   24:      99 bytes      5 times -->      9.89 Mbps in      76.40 usec
> >>   25:     125 bytes      5 times -->     12.10 Mbps in      78.80 usec
> >>   26:     128 bytes      5 times -->     12.27 Mbps in      79.60 usec
> >>   27:     131 bytes      5 times -->     12.80 Mbps in      78.10 usec
> >>   28:     189 bytes      5 times -->     18.00 Mbps in      80.10 usec
> >>   29:     192 bytes      5 times -->     18.31 Mbps in      80.00 usec
> >>   30:     195 bytes      5 times -->     18.41 Mbps in      80.80 usec
> >>   31:     253 bytes      5 times -->     23.34 Mbps in      82.70 usec
> >>   32:     256 bytes      5 times -->     23.91 Mbps in      81.70 usec
> >>   33:     259 bytes      5 times -->     24.19 Mbps in      81.70 usec
> >>   34:     381 bytes      5 times -->     33.18 Mbps in      87.60 usec
> >>   35:     384 bytes      5 times -->     33.87 Mbps in      86.50 usec
> >>   36:     387 bytes      5 times -->     34.41 Mbps in      85.80 usec
> >>   37:     509 bytes      5 times -->     42.72 Mbps in      90.90 usec
> >>   38:     512 bytes      5 times -->     42.60 Mbps in      91.70 usec
> >>   39:     515 bytes      5 times -->     42.80 Mbps in      91.80 usec
> >>   40:     765 bytes      5 times -->     56.45 Mbps in     103.40 usec
> >>   41:     768 bytes      5 times -->     57.11 Mbps in     102.60 usec
> >>   42:     771 bytes      5 times -->     57.22 Mbps in     102.80 usec
> >>   43:    1021 bytes      5 times -->     70.69 Mbps in     110.20 usec
> >>   44:    1024 bytes      5 times -->     70.70 Mbps in     110.50 usec
> >>   45:    1027 bytes      5 times -->     69.59 Mbps in     112.60 usec
> >>   46:    1533 bytes      5 times -->     73.56 Mbps in     159.00 usec
> >>   47:    1536 bytes      5 times -->     72.92 Mbps in     160.70 usec
> >>   48:    1539 bytes      5 times -->     73.80 Mbps in     159.10 usec
> >>   49:    2045 bytes      5 times -->     93.59 Mbps in     166.70 usec
> >>   50:    2048 bytes      5 times -->     94.07 Mbps in     166.10 usec
> >>   51:    2051 bytes      5 times -->     92.92 Mbps in     168.40 usec
> >>   52:    3069 bytes      5 times -->    123.43 Mbps in     189.70 usec
> >>   53:    3072 bytes      5 times -->    123.68 Mbps in     189.50 usec
> >
> >You are right. Unfortunately, this does not work on i.MX28 (at least for
> >me). Couldn't it be that the cpufreq is masking the problem on the i.MX6?
> >
> >Best regards,
> >--
> >Hector Palacios
> 
> I reproduce the issue on imx28 evk platform, imx28 has no specific cpufreq
> driver. In kernel 3.13, the ethernet driver is almost the same for imx28
> and imx6 since they use the Same enet IP, but imx6 enet IP have some
> evolution.
> 
> Now I don't know the cause. When I am free, I will dig out it.

Hi! Is there any progress on this issue ? Did you manage to find anything out 
please?

Best regards,
Marek Vasut
