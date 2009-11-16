From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 04:24:29 -0800 (PST)
Message-ID: <20091116.042429.194566531.davem@davemloft.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B950BFF@zin33exm22.fsl.freescale.net>
	<20091116.030504.268003197.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B950C11@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34634
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753011AbZKPMYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 07:24:15 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950C11@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Mon, 16 Nov 2009 17:26:33 +0530

> In the current implemnetation, the ->poll() function does the cleanup of
> the tx and rx rings of the same device.
> In case of forwarding scenarios (for eg, eth0 --> eth1) we should clean
> the tx ring of eth1 so that the buffers can be reclaimed and they be
> reused for eth0 RX and same is the case for opposite flow. With the
> current implementation there will be a problem for the bidirectional
> flow as a ->poll() function will try to cleanup the rx and tx ring of
> the same device.
> 
> Hence I feel, if we separate out the tx and rx clean ring processes, it
> would be more advantageous as the reclaim process can be more effective.

Eric Dumazet is working on patches to make sure the TX frees
get scheduled on the same CPU as they were transmitted on.

Therefore, you shouldn't try to approximate this in your driver.
