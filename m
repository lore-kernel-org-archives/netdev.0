From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve
 proformance
Date: Tue, 22 Jan 2013 22:21:11 -0800
Message-ID: <1358922071.12374.743.camel@edumazet-glaptop>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:48645 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab3AWGVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 01:21:14 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so3610640dak.19
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 22:21:14 -0800 (PST)
In-Reply-To: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 12:12 +0800, Frank Li wrote:
> Add napi support
> 
> Before this patch
> 
>  iperf -s -i 1
>  ------------------------------------------------------------
>  Server listening on TCP port 5001
>  TCP window size: 85.3 KByte (default)
>  ------------------------------------------------------------
>  [  4] local 10.192.242.153 port 5001 connected with 10.192.242.138 port 50004
>  [ ID] Interval       Transfer     Bandwidth
>  [  4]  0.0- 1.0 sec  41.2 MBytes   345 Mbits/sec
>  [  4]  1.0- 2.0 sec  43.7 MBytes   367 Mbits/sec
>  [  4]  2.0- 3.0 sec  42.8 MBytes   359 Mbits/sec
>  [  4]  3.0- 4.0 sec  43.7 MBytes   367 Mbits/sec
>  [  4]  4.0- 5.0 sec  42.7 MBytes   359 Mbits/sec
>  [  4]  5.0- 6.0 sec  43.8 MBytes   367 Mbits/sec
>  [  4]  6.0- 7.0 sec  43.0 MBytes   361 Mbits/sec
> 
> After this patch
>  [  4]  2.0- 3.0 sec  51.6 MBytes   433 Mbits/sec
>  [  4]  3.0- 4.0 sec  51.8 MBytes   435 Mbits/sec
>  [  4]  4.0- 5.0 sec  52.2 MBytes   438 Mbits/sec
>  [  4]  5.0- 6.0 sec  52.1 MBytes   437 Mbits/sec
>  [  4]  6.0- 7.0 sec  52.1 MBytes   437 Mbits/sec
>  [  4]  7.0- 8.0 sec  52.3 MBytes   439 Mbits/sec

Strange, as you still call netif_rx()

NAPI should call netif_receive_skb() instead
