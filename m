From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] gianfar: Implement workaround for eTSEC-A002
 erratum
Date: Wed, 30 Jun 2010 11:37:27 -0700 (PDT)
Message-ID: <20100630.113727.257507106.davem@davemloft.net>
References: <20100630163804.GA636@oksana.dev.rtsoft.ru>
	<20100630163915.GC23337@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757030Ab0F3ShN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 14:37:13 -0400
In-Reply-To: <20100630163915.GC23337@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Wed, 30 Jun 2010 20:39:15 +0400

> MPC8313ECE says:
> 
> "If the controller receives a 1- or 2-byte frame (such as an illegal
>  runt packet or a packet with RX_ER asserted) before GRS is asserted
>  and does not receive any other frames, the controller may fail to set
>  GRSC even when the receive logic is completely idle. Any subsequent
>  receive frame that is larger than two bytes will reset the state so
>  the graceful stop can complete. A MAC receiver (Rx) reset will also
>  reset the state."
> 
> This patch implements the proposed workaround:
> 
> "If IEVENT[GRSC] is still not set after the timeout, read the eTSEC
>  register at offset 0xD1C. If bits 7-14 are the same as bits 23-30,
>  the eTSEC Rx is assumed to be idle and the Rx can be safely reset.
>  If the register fields are not equal, wait for another timeout
>  period and check again."
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Applied.
