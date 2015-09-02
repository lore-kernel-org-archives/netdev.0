From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Wed, 02 Sep 2015 11:25:00 -0700 (PDT)
Message-ID: <20150902.112500.2176991714061589322.davem@davemloft.net>
References: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org
To: nemoto@toshiba-tops.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbbIBSZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:25:03 -0400
In-Reply-To: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Date: Wed, 2 Sep 2015 17:49:29 +0900

> tse_poll() calls __napi_complete() with irq enabled.  This leads napi
> poll_list corruption and may stop all napi drivers working.
> Use napi_complete() instead of __napi_complete().
> 
> Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>

Two lines below this change you are disabling interrupts anyways,
so I would suggest just moving the spin_lock_irqsave() before the
napi_gro_flush() to fix this.

Many of the checks done by napi_complete_done() (invoked by
napi_complete()) are completely redundant in this context.  For
example, the direct __napi_complete() call is a really nice
optimization because we know we are on the poll list and therefore
it is not empty.
