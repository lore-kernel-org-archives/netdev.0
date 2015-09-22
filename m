From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] 8139cp: Do not re-enable RX interrupts in
 cp_tx_timeout()
Date: Tue, 22 Sep 2015 16:46:05 -0700 (PDT)
Message-ID: <20150922.164605.1844169715316631068.davem@davemloft.net>
References: <1442843991.7367.4.camel@infradead.org>
	<1442844127.7367.11.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758811AbbIVXqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:46:06 -0400
In-Reply-To: <1442844127.7367.11.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 21 Sep 2015 15:02:07 +0100

> From: David Woodhouse <David.Woodhouse@intel.com>
> 
> If an RX interrupt was already received but NAPI has not yet run when
> the RX timeout happens, we end up in cp_tx_timeout() with RX interrupts
> already disabled. Blindly re-enabling them will cause an IRQ storm.
> 
> This is somewhat less painful than it was a few minutes ago before I
> fixed the return value from cp_interrupt(), but still suboptimal.
> 
> Unconditionally leave RX interrupts disabled after the reset, and
> schedule NAPI to check the receive ring and re-enable them.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

As I said, if this makes your IRQ storms go away then therefore it
obviates the need for patch #1.
