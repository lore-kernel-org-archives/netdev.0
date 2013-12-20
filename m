From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: FEC performance degradation with certain packet sizes
Date: Fri, 20 Dec 2013 03:35:57 +0000
Message-ID: <9f5c7cffc9154d1892cbbc0040d89581@BLUPR03MB373.namprd03.prod.outlook.com>
References: <528F50AE.3030804@digi.com> <201311240540.23813.marex@denx.de>
 <529310A4.70906@digi.com> <52B1D0C6.6010305@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Hector Palacios <hector.palacios@digi.com>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0183.outbound.protection.outlook.com ([207.46.163.183]:17944
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751832Ab3LTDgB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 22:36:01 -0500
In-Reply-To: <52B1D0C6.6010305@digi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hector Palacios <hector.palacios@digi.com>
Data: Thursday, December 19, 2013 12:44 AM

>To: Marek Vasut; netdev@vger.kernel.org
>Cc: Estevam Fabio-R49496; shawn.guo@linaro.org; l.stach@pengutronix.de; Li
>Frank-B20596; Duan Fugang-B38611; bhutchings@solarflare.com;
>davem@davemloft.net
>Subject: Re: FEC performance degradation with certain packet sizes
>
>Hello,
>
>I'm resending this thread (reworded the subject) with additional people on CC.
>I found the issue happens also with auto-negotiated link and is reproducible on
>the
>i.MX6 as well as on the i.MX28. It looks like a problem with the fec driver.
>
>Steps to reproduce:
>On the target:
>	netpipe
>On the host:
>	netpipe -h <target_ip> -n 5
>
>At certain packet sizes (starting always at 1533 bytes), the performance drops
>dramatically:
>
>On i.MX28:
>[...]
>  42:     771 bytes      5 times -->     19.78 Mbps in     297.41 usec
>  43:    1021 bytes      5 times -->     23.29 Mbps in     334.41 usec
>  44:    1024 bytes      5 times -->     23.61 Mbps in     330.90 usec
>  45:    1027 bytes      5 times -->     23.43 Mbps in     334.41 usec
>  46:    1533 bytes      5 times -->      0.13 Mbps in   88817.49 usec
>  47:    1536 bytes      5 times -->      0.06 Mbps in  189914.91 usec
>  48:    1539 bytes      5 times -->      0.06 Mbps in  204917.19 usec
>  49:    2045 bytes      5 times -->      0.07 Mbps in  210931.79 usec
>  50:    2048 bytes      5 times -->      0.07 Mbps in  210919.10 usec
>  51:    2051 bytes      5 times -->      0.07 Mbps in  212915.71 usec
>  52:    3069 bytes      5 times -->     35.42 Mbps in     661.01 usec
>  53:    3072 bytes      5 times -->     35.57 Mbps in     659.00 usec
>  54:    3075 bytes      5 times -->     35.42 Mbps in     662.29 usec
>  55:    4093 bytes      5 times -->     40.03 Mbps in     780.19 usec
>  56:    4096 bytes      5 times -->     40.75 Mbps in     766.79 usec
>  57:    4099 bytes      5 times -->     40.64 Mbps in     769.49 usec
>  58:    6141 bytes      5 times -->      3.08 Mbps in   15187.90 usec
>  59:    6144 bytes      5 times -->      2.94 Mbps in   15928.19 usec
>  60:    6147 bytes      5 times -->      5.57 Mbps in    8418.91 usec
>  61:    8189 bytes      5 times -->      1.34 Mbps in   46574.90 usec
>  62:    8192 bytes      5 times -->      2.17 Mbps in   28781.99 usec
>  63:    8195 bytes      5 times -->      1.36 Mbps in   45923.69 usec
>  64:   12285 bytes      5 times -->     51.78 Mbps in    1810.21 usec
>  65:   12288 bytes      5 times -->     50.46 Mbps in    1857.81 usec
>  66:   12291 bytes      5 times -->     54.01 Mbps in    1736.21 usec
>  67:   16381 bytes      5 times -->     55.86 Mbps in    2237.50 usec
>  68:   16384 bytes      5 times -->     56.93 Mbps in    2195.79 usec
>  69:   16387 bytes      5 times -->     35.62 Mbps in    3509.60 usec
>  70:   24573 bytes      5 times -->      7.19 Mbps in   26075.60 usec
>  71:   24576 bytes      5 times -->     58.36 Mbps in    3212.59 usec
>  72:   24579 bytes      5 times -->      7.92 Mbps in   23678.90 usec
>  73:   32765 bytes      5 times -->     58.14 Mbps in    4299.79 usec
>  74:   32768 bytes      5 times -->      5.34 Mbps in   46810.20 usec
>  75:   32771 bytes      5 times -->     41.51 Mbps in    6023.21 usec
>  76:   49149 bytes      5 times -->     49.62 Mbps in    7557.20 usec
>  77:   49152 bytes      5 times -->     48.82 Mbps in    7681.11 usec
>
>On i.MX6:
>[...]
>  42:     771 bytes      5 times -->     16.21 Mbps in     362.91 usec
>  43:    1021 bytes      5 times -->     17.97 Mbps in     433.51 usec
>  44:    1024 bytes      5 times -->     18.19 Mbps in     429.40 usec
>  45:    1027 bytes      5 times -->     18.16 Mbps in     431.41 usec
>  46:    1533 bytes      5 times -->      2.35 Mbps in    4970.11 usec
>  47:    1536 bytes      5 times -->      2.36 Mbps in    4959.91 usec
>  48:    1539 bytes      5 times -->      2.37 Mbps in    4959.20 usec
>  49:    2045 bytes      5 times -->      3.14 Mbps in    4972.31 usec
>  50:    2048 bytes      5 times -->      3.15 Mbps in    4959.50 usec
>  51:    2051 bytes      5 times -->      3.15 Mbps in    4960.01 usec
>  52:    3069 bytes      5 times -->      4.70 Mbps in    4984.19 usec
>  53:    3072 bytes      5 times -->      4.73 Mbps in    4960.10 usec
>  54:    3075 bytes      5 times -->      4.73 Mbps in    4957.81 usec
>  55:    4093 bytes      5 times -->      6.29 Mbps in    4966.71 usec
>  56:    4096 bytes      5 times -->      6.30 Mbps in    4962.00 usec
>  57:    4099 bytes      5 times -->      6.31 Mbps in    4957.71 usec
>  58:    6141 bytes      5 times -->     49.25 Mbps in     951.40 usec
>  59:    6144 bytes      5 times -->     49.23 Mbps in     952.21 usec
>  60:    6147 bytes      5 times -->     49.18 Mbps in     953.69 usec
>
>Does anyone have any clue about where the problem might be?
>
>Best regards,
>--
>Hector Palacios
>

I can reproduce the issue on imx6q/dl platform with freescale internal kernel tree.

This issue must be related to cpufreq, when set scaling_governor to performance:
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

And then do NPtcp test, the result as below:

 24:      99 bytes      5 times -->      9.89 Mbps in      76.40 usec
 25:     125 bytes      5 times -->     12.10 Mbps in      78.80 usec
 26:     128 bytes      5 times -->     12.27 Mbps in      79.60 usec
 27:     131 bytes      5 times -->     12.80 Mbps in      78.10 usec
 28:     189 bytes      5 times -->     18.00 Mbps in      80.10 usec
 29:     192 bytes      5 times -->     18.31 Mbps in      80.00 usec
 30:     195 bytes      5 times -->     18.41 Mbps in      80.80 usec
 31:     253 bytes      5 times -->     23.34 Mbps in      82.70 usec
 32:     256 bytes      5 times -->     23.91 Mbps in      81.70 usec
 33:     259 bytes      5 times -->     24.19 Mbps in      81.70 usec
 34:     381 bytes      5 times -->     33.18 Mbps in      87.60 usec
 35:     384 bytes      5 times -->     33.87 Mbps in      86.50 usec
 36:     387 bytes      5 times -->     34.41 Mbps in      85.80 usec
 37:     509 bytes      5 times -->     42.72 Mbps in      90.90 usec
 38:     512 bytes      5 times -->     42.60 Mbps in      91.70 usec
 39:     515 bytes      5 times -->     42.80 Mbps in      91.80 usec
 40:     765 bytes      5 times -->     56.45 Mbps in     103.40 usec
 41:     768 bytes      5 times -->     57.11 Mbps in     102.60 usec
 42:     771 bytes      5 times -->     57.22 Mbps in     102.80 usec
 43:    1021 bytes      5 times -->     70.69 Mbps in     110.20 usec
 44:    1024 bytes      5 times -->     70.70 Mbps in     110.50 usec
 45:    1027 bytes      5 times -->     69.59 Mbps in     112.60 usec
 46:    1533 bytes      5 times -->     73.56 Mbps in     159.00 usec
 47:    1536 bytes      5 times -->     72.92 Mbps in     160.70 usec
 48:    1539 bytes      5 times -->     73.80 Mbps in     159.10 usec
 49:    2045 bytes      5 times -->     93.59 Mbps in     166.70 usec
 50:    2048 bytes      5 times -->     94.07 Mbps in     166.10 usec
 51:    2051 bytes      5 times -->     92.92 Mbps in     168.40 usec
 52:    3069 bytes      5 times -->    123.43 Mbps in     189.70 usec
 53:    3072 bytes      5 times -->    123.68 Mbps in     189.50 usec


Thanks,
Andy
