From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] sfc: Report TX completions to BQL after all TX
 events in interrupt
Date: Thu, 09 Jul 2015 00:00:58 -0700 (PDT)
Message-ID: <20150709.000058.55757353896312409.davem@davemloft.net>
References: <559CE7C6.7040701@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbbGIHA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 03:00:59 -0400
In-Reply-To: <559CE7C6.7040701@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 8 Jul 2015 10:05:10 +0100

> From: Peter Dunning <pdunning@solarflare.com>
> 
> The limit for BQL is updated each time we call
> netdev_tx_completed_queue.
> Without this patch the BQL limit was updated for every TX event we
> see.
> The issue was that this only updated the limit to handle the data
> we complete in two events as the first event wouldn't show that
> enough traffic had been processed between them.
> 
> This was OK when interrupt moderation was off but not when it was
> on as more data had to be completed in a single interrupt.
> 
> The patch changes this so that we do report the completion to BQL
> only when all the TX events in the interrupt have been processed.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
