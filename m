From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macb: process the RX ring regardless of interrupt
 status
Date: Fri, 17 Apr 2009 01:31:07 -0700 (PDT)
Message-ID: <20090417.013107.41038229.davem@davemloft.net>
References: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
	<1239874331-9431-2-git-send-email-haavard.skinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	erik.waling@konftel.com
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbZDQIbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:31:15 -0400
In-Reply-To: <1239874331-9431-2-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Thu, 16 Apr 2009 11:32:11 +0200

> Suppose that we receive lots of frames, start processing them, but
> exhaust our budget so that we return before we had a chance to look
> at all of them.
> 
> Then, when the network layer calls us again, we will only continue
> processing the buffers if the REC bit was set in the mean time, which it
> might not be if there was a brief pause in the flow of packets. If this
> happens, we'll simply display a warning and call netif_rx_complete()
> with potentially lots of unprocessed packets in the RX ring...
> 
> Fix this by scanning the ring no matter what flags are set in the
> interrupt status register.
> 
> Signed-off-by: Erik Waling <erik.waling@konftel.com>
> Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

Applied.
