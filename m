From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] cpmac: prevent fatal exception in
 cpmac_end_xmit
Date: Mon, 01 Jun 2009 02:58:18 -0700 (PDT)
Message-ID: <20090601.025818.156394734.davem@davemloft.net>
References: <200905312259.16127.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756143AbZFAJ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 05:58:18 -0400
In-Reply-To: <200905312259.16127.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 31 May 2009 22:59:15 +0200

> From: Stefan Weil <weil@mail.berlios.de>
> 
> We should not be stopping the subqueues in cpmac_end_xmit
> but rather test the status of them. Replace the calls to
> netif_subqueue_stop by __netif_subqueue_stopped. This
> fixes an unrecoverable exception from happening when
> running the driver.
> 
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, but this commit message was completely wrong and
therefore misleading to anyone trying to track down why this
change was made.

The problem is that netif_subqueue_stopped() takes a SKB
pointer, whereas we're passing in an integer queue index
here.

Therefore, merely providing the obvious compile warning that
was produced by this incorrect argument type would have
explained everything, and accurately.
