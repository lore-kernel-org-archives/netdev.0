From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 17:26:33 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950C11@zin33exm22.fsl.freescale.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net><20091116.024130.156214496.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B950BFF@zin33exm22.fsl.freescale.net> <20091116.030504.268003197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <vladz@broadcom.com>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:62261 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbZKPL4e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:56:34 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nAGBuavZ011446
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 04:56:36 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nAGC04KN013247
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 06:00:05 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091116.030504.268003197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>> I was talking about an independent napi routine for cleaning 
>tx ring, 
>> I do not want to mix the rx and tx clean ring processes.
>
>But you absolutely should do this, it will give optimal performance.
>

In the current implemnetation, the ->poll() function does the cleanup of
the tx and rx rings of the same device.
In case of forwarding scenarios (for eg, eth0 --> eth1) we should clean
the tx ring of eth1 so that the buffers can be reclaimed and they be
reused for eth0 RX and same is the case for opposite flow. With the
current implementation there will be a problem for the bidirectional
flow as a ->poll() function will try to cleanup the rx and tx ring of
the same device.

Hence I feel, if we separate out the tx and rx clean ring processes, it
would be more advantageous as the reclaim process can be more effective.


--

Thanks
Sandeep 
