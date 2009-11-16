From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 02:41:30 -0800 (PST)
Message-ID: <20091116.024130.156214496.davem@davemloft.net>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
	<20091116.022012.81633492.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445AbZKPKlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:41:14 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Mon, 16 Nov 2009 16:02:04 +0530

> Can we actually introduce NAPI mechanism for cleaning TX ring ??

You really should if you can.

Preferably you should combine it with RX work in a shared NAPI context
(1 TX queue + 1 RX queue per NAPI context, for example), doing the TX
reclaim first in your ->poll() routine, before the RX processing,
because this TX reclaim provides freshly freed up SKBs for RX work
that generates responses (TCP ACKs, etc.)
