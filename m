From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: fix occasional BUG during MTU change
Date: Mon, 13 Apr 2009 16:23:29 -0700 (PDT)
Message-ID: <20090413.162329.83864908.davem@davemloft.net>
References: <20090407183623.7545bb0b@leela>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752686AbZDMXXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 19:23:38 -0400
In-Reply-To: <20090407183623.7545bb0b@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue, 7 Apr 2009 18:36:23 +0200

> The BUG_ON(skge->tx_ring.to_use != skge->tx_ring.to_clean) in skge_up()
> was sometimes observed when setting MTU.
> 
> skge_down() disables the TX queue, but then reenables it by mistake via
> skge_tx_clean().
> Fix it by moving the waking of the queue from skge_tx_clean() to the
> other caller. And to make sure start_xmit is not in progress on another
> CPU, skge_down() should call netif_tx_disable().
> 
> The bug was reported to me by Jiri Jilek whose Debian system sometimes
> failed to boot. He tested the patch and the bug did not happen anymore.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Stephen have you had a chance to test this yet?

Thanks.
