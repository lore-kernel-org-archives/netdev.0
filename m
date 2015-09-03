From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Thu, 3 Sep 2015 09:52:57 +0900
Message-ID: <20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
References: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
	<20150902.112500.2176991714061589322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <vbridger@opensource.altera.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsowa.toshiba-tops.co.jp ([61.200.21.19]:63428 "EHLO
	TPSSRV64.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755588AbbICAxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 20:53:16 -0400
In-Reply-To: <20150902.112500.2176991714061589322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2015 11:25:00 -0700, David Miller <davem@davemloft.net> wrote:
> Two lines below this change you are disabling interrupts anyways,
> so I would suggest just moving the spin_lock_irqsave() before the
> napi_gro_flush() to fix this.
> 
> Many of the checks done by napi_complete_done() (invoked by
> napi_complete()) are completely redundant in this context.  For
> example, the direct __napi_complete() call is a really nice
> optimization because we know we are on the poll list and therefore
> it is not empty.

Thank you for your suggestion.

I think napi_gro_flush() can be called with irq enabled, so moving the
spin_lock_irqsave() just before the __napi_complete() (or moving the
__napi_complete() just after the spin_lock_irqsave()) would be better,
right?
