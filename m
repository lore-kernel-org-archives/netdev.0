From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix unconditionally returning
 IRQ_HANDLED in INTx
Date: Sat, 12 Jan 2013 01:21:46 -0800 (PST)
Message-ID: <20130112.012146.1746775070657245621.davem@davemloft.net>
References: <ac9920f8-3e7c-4920-8323-510e648822c8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3ALJVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 04:21:49 -0500
In-Reply-To: <ac9920f8-3e7c-4920-8323-510e648822c8@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Sat, 12 Jan 2013 14:17:02 +0530

> commit e49cc34f introduced an unconditional IRQ_HANDLED return in be_intx()
> to workaround Lancer and BE2 HW issues. This is bad as it prevents the kernel
> from detecting interrupt storms due to broken HW.
> 
> The BE2/Lancer HW issues are:
> 1) In Lancer, there is no means for the driver to detect if the interrupt
> belonged to device, other than counting and notifying events.
> 2) In Lancer de-asserting INTx takes a while, causing the INTx irq handler
> to be called multiple times till the de-assert happens.
> 3) In BE2, we see an occasional interrupt even when EQs are unarmed.
> 
> Issue (1) can cause the notified events to be orphaned, if NAPI was already
> running.
> This patch fixes this issue by scheduling NAPI only if it is not scheduled
> already. Doing this also takes care of possible events_get() race that may be
> caused due to issue (2) and (3). Also, IRQ_HANDLED is returned only the first
> time zero events are detected.
> (Thanks Ben H. for the feedback and suggestions.)
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Any particular reason why we shouldn't put this fix into 'net' instead
of 'net-next'?
