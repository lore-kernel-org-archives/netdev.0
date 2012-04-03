From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: Don't stop and restart queue on every TX packet
Date: Tue, 03 Apr 2012 17:29:58 -0400 (EDT)
Message-ID: <20120403.172958.144419545310336164.davem@davemloft.net>
References: <1332672230.32446.160.camel@shinybook.infradead.org>
	<20120325.173635.1909319488008466320.davem@davemloft.net>
	<1332756222.2379.66.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab2DCVbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:31:12 -0400
In-Reply-To: <1332756222.2379.66.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 26 Mar 2012 11:03:42 +0100

> For every transmitted packet, ppp_start_xmit() will stop the netdev
> queue and then, if appropriate, restart it. This causes the TX softirq
> to run, entirely gratuitously.
> 
> This is "only" a waste of CPU time in the normal case, but it's actively
> harmful when the PPP device is a TEQL slave ― the wakeup will cause the
> offending device to receive the next TX packet from the TEQL queue, when
> it *should* have gone to the next slave in the list. We end up seeing
> large bursts of packets on just *one* slave device, rather than using
> the full available bandwidth over all slaves.
> 
> This patch fixes the problem by *not* unconditionally stopping the queue
> in ppp_start_xmit(). It adds a return value from ppp_xmit_process()
> which indicates whether the queue should be stopped or not.
> 
> It *doesn't* remove the call to netif_wake_queue() from
> ppp_xmit_process(), because other code paths (especially from
> ppp_output_wakeup()) need it there and it's messy to push it out to the
> other callers to do it based on the return value. So we leave it in
> place ― it's a no-op in the case where the queue wasn't stopped, so it's
> harmless in the TX path.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied, thanks.  But:

> --- drivers/net/ppp/ppp_generic.c~	2012-01-26 00:39:32.000000000 +0000
> +++ drivers/net/ppp/ppp_generic.c	2012-03-26 10:32:31.286744147 +0100

Please -p1 root your patches in the future.
