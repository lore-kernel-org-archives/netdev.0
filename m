From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: Do not call tcp_fastopen_reset_cipher from
 interrupt context
Date: Tue, 23 Jun 2015 02:53:50 -0700 (PDT)
Message-ID: <20150623.025350.1033684750230291393.davem@davemloft.net>
References: <1434644134-81335-1-git-send-email-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org
To: cpaasch@apple.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbbFWJmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:42:02 -0400
In-Reply-To: <1434644134-81335-1-git-send-email-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <cpaasch@apple.com>
Date: Thu, 18 Jun 2015 09:15:34 -0700

> tcp_fastopen_reset_cipher really cannot be called from interrupt
> context. It allocates the tcp_fastopen_context with GFP_KERNEL and
> calls crypto_alloc_cipher, which allocates all kind of stuff with
> GFP_KERNEL.
> 
> Thus, we might sleep when the key-generation is triggered by an
> incoming TFO cookie-request which would then happen in interrupt-
> context, as shown by enabling CONFIG_DEBUG_ATOMIC_SLEEP:
 ...
> This patch moves the call to tcp_fastopen_init_key_once to the places
> where a listener socket creates its TFO-state, which always happens in
> user-context (either from the setsockopt, or implicitly during the
> listen()-call)
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Fixes: 222e83d2e0ae ("tcp: switch tcp_fastopen key generation to net_get_random_once")
> Signed-off-by: Christoph Paasch <cpaasch@apple.com>

Applied and queued up for -stable, thanks.
