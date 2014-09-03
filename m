From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Patch net-next 04/11] net:fec: add multiqueue support
Date: Wed, 03 Sep 2014 14:27:21 -0700
Message-ID: <540787B9.8090504@gmail.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com> <1409776697-1536-5-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>, b38611@freescale.com,
	davem@davemloft.net, netdev@vger.kernel.org, lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64971 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659AbaICV2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:28:00 -0400
In-Reply-To: <1409776697-1536-5-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 01:38 PM, Frank Li wrote:
> From: Fugang Duan <B38611@freescale.com>
> 
> Add multiqueue support, which is compatible with previous single queue
> driver for FEC/ENET IPs.
> 
> By default, the tx/rx queue number is 1, user can config the queue number
> at DTS file like this:
> 	fsl,num_tx_queues=<3>;
> 	fsl,num_rx_queues=<3>;
> 
> Ethernet multiqueue mechanism can improve performance in SMP system.
> For single hw queue, multiqueue can balance cpu loading.
> For multi hw queues, multiple cores can process network packets in parallel,
> and refer the article for the detail advantage for multiqueue:
> http://vger.kernel.org/~davem/davem_nyc09.pdf

You should probably split that patch in a minimum of two, or more
different parts.

Two parts:

- add TX multiqueue support
- add RX multiqueue support

More parts:

- prepare for TX multiqueue (introduce queue structure, definitions)
- transition TX path to use queue 0
- add support for the two other TX queues
- prepare for RX multiqueue (introduce queue structure, definitions)
- prepare for multiqueue, hardcode RX path to use queue 0
- add support for the two other RX queues

The number of changes are extremely hard to review...
--
Florian
