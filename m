From: David Miller <davem@davemloft.net>
Subject: Re: BNX2X driver: kernel panic when running netperf
Date: Tue, 16 Oct 2007 16:49:38 -0700 (PDT)
Message-ID: <20071016.164938.66177554.davem@davemloft.net>
References: <1192577680.5730.12.camel@w-amax.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: masbock@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752399AbXJPXtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 19:49:33 -0400
In-Reply-To: <1192577680.5730.12.camel@w-amax.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Max Asbock <masbock@us.ibm.com>
Date: Tue, 16 Oct 2007 16:34:40 -0700

> I tested the bnx2x driver (0001-BNX2X-0.40.10a-net-2.6.24.patch) with
> netdev-2.6.24 git tree and found that I can reproducibly panic the
> system when running netperf with the TCP_STREAM test.
> I copied the following information from the panic message:
> RIP: 0xc02fff32
> net_rx_action +0x142/0x190

The driver is doing netif_rx_complete() yet returning a value from
->poll() which is >= budget, which is illegal.

We had to fix a similar bug in the tg3 and bnx2 drivers, the same
logic probably just propagated itself into bnx2x.
