From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: FEC performance degradation with certain packet sizes
Date: Wed, 18 Dec 2013 09:38:59 -0800
Message-ID: <1387388339.19078.321.camel@edumazet-glaptop2.roam.corp.google.com>
References: <528F50AE.3030804@digi.com> <201311240540.23813.marex@denx.de>
	 <529310A4.70906@digi.com> <52B1D0C6.6010305@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	l.stach@pengutronix.de, Frank Li <Frank.Li@freescale.com>,
	fugang.duan@freescale.com, bhutchings@solarflare.com,
	"davem@davemloft.net" <davem@davemloft.net>
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:38497 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab3LRRi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 12:38:57 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so6268155pad.38
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 09:38:57 -0800 (PST)
In-Reply-To: <52B1D0C6.6010305@digi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 17:43 +0100, Hector Palacios wrote:
> Hello,
> 
> I'm resending this thread (reworded the subject) with additional people on CC.
> I found the issue happens also with auto-negotiated link and is reproducible on the 
> i.MX6 as well as on the i.MX28. It looks like a problem with the fec driver.
> 
> Steps to reproduce:
> On the target:
> 	netpipe
> On the host:
> 	netpipe -h <target_ip> -n 5
> 
> At certain packet sizes (starting always at 1533 bytes), the performance drops 
> dramatically:
> 
> On i.MX28:
> [...]
>   42:     771 bytes      5 times -->     19.78 Mbps in     297.41 usec
>   43:    1021 bytes      5 times -->     23.29 Mbps in     334.41 usec
>   44:    1024 bytes      5 times -->     23.61 Mbps in     330.90 usec
>   45:    1027 bytes      5 times -->     23.43 Mbps in     334.41 usec
>   46:    1533 bytes      5 times -->      0.13 Mbps in   88817.49 usec
>   47:    1536 bytes      5 times -->      0.06 Mbps in  189914.91 usec
>   48:    1539 bytes      5 times -->      0.06 Mbps in  204917.19 usec
>   49:    2045 bytes      5 times -->      0.07 Mbps in  210931.79 usec
>   50:    2048 bytes      5 times -->      0.07 Mbps in  210919.10 usec
>   51:    2051 bytes      5 times -->      0.07 Mbps in  212915.71 usec
>   52:    3069 bytes      5 times -->     35.42 Mbps in     661.01 usec
>   53:    3072 bytes      5 times -->     35.57 Mbps in     659.00 usec
>   54:    3075 bytes      5 times -->     35.42 Mbps in     662.29 usec
>   55:    4093 bytes      5 times -->     40.03 Mbps in     780.19 usec
>   56:    4096 bytes      5 times -->     40.75 Mbps in     766.79 usec
>   57:    4099 bytes      5 times -->     40.64 Mbps in     769.49 usec
>   58:    6141 bytes      5 times -->      3.08 Mbps in   15187.90 usec
>   59:    6144 bytes      5 times -->      2.94 Mbps in   15928.19 usec
>   60:    6147 bytes      5 times -->      5.57 Mbps in    8418.91 usec
>   61:    8189 bytes      5 times -->      1.34 Mbps in   46574.90 usec
>   62:    8192 bytes      5 times -->      2.17 Mbps in   28781.99 usec
>   63:    8195 bytes      5 times -->      1.36 Mbps in   45923.69 usec
>   64:   12285 bytes      5 times -->     51.78 Mbps in    1810.21 usec
>   65:   12288 bytes      5 times -->     50.46 Mbps in    1857.81 usec
>   66:   12291 bytes      5 times -->     54.01 Mbps in    1736.21 usec
>   67:   16381 bytes      5 times -->     55.86 Mbps in    2237.50 usec
>   68:   16384 bytes      5 times -->     56.93 Mbps in    2195.79 usec
>   69:   16387 bytes      5 times -->     35.62 Mbps in    3509.60 usec
>   70:   24573 bytes      5 times -->      7.19 Mbps in   26075.60 usec
>   71:   24576 bytes      5 times -->     58.36 Mbps in    3212.59 usec
>   72:   24579 bytes      5 times -->      7.92 Mbps in   23678.90 usec
>   73:   32765 bytes      5 times -->     58.14 Mbps in    4299.79 usec
>   74:   32768 bytes      5 times -->      5.34 Mbps in   46810.20 usec
>   75:   32771 bytes      5 times -->     41.51 Mbps in    6023.21 usec
>   76:   49149 bytes      5 times -->     49.62 Mbps in    7557.20 usec
>   77:   49152 bytes      5 times -->     48.82 Mbps in    7681.11 usec
> 
> On i.MX6:
> [...]
>   42:     771 bytes      5 times -->     16.21 Mbps in     362.91 usec
>   43:    1021 bytes      5 times -->     17.97 Mbps in     433.51 usec
>   44:    1024 bytes      5 times -->     18.19 Mbps in     429.40 usec
>   45:    1027 bytes      5 times -->     18.16 Mbps in     431.41 usec
>   46:    1533 bytes      5 times -->      2.35 Mbps in    4970.11 usec
>   47:    1536 bytes      5 times -->      2.36 Mbps in    4959.91 usec
>   48:    1539 bytes      5 times -->      2.37 Mbps in    4959.20 usec
>   49:    2045 bytes      5 times -->      3.14 Mbps in    4972.31 usec
>   50:    2048 bytes      5 times -->      3.15 Mbps in    4959.50 usec
>   51:    2051 bytes      5 times -->      3.15 Mbps in    4960.01 usec
>   52:    3069 bytes      5 times -->      4.70 Mbps in    4984.19 usec
>   53:    3072 bytes      5 times -->      4.73 Mbps in    4960.10 usec
>   54:    3075 bytes      5 times -->      4.73 Mbps in    4957.81 usec
>   55:    4093 bytes      5 times -->      6.29 Mbps in    4966.71 usec
>   56:    4096 bytes      5 times -->      6.30 Mbps in    4962.00 usec
>   57:    4099 bytes      5 times -->      6.31 Mbps in    4957.71 usec
>   58:    6141 bytes      5 times -->     49.25 Mbps in     951.40 usec
>   59:    6144 bytes      5 times -->     49.23 Mbps in     952.21 usec
>   60:    6147 bytes      5 times -->     49.18 Mbps in     953.69 usec
> 
> Does anyone have any clue about where the problem might be?

What is the driver in use ?

Have you tried disabling tso/gso ?

ethtool -k eth0

ethtool -K eth0 tso off gso off
