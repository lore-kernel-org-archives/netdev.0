From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: avoid NAPI scheduling delay.
Date: Sun, 10 Jun 2012 20:21:28 -0700 (PDT)
Message-ID: <20120610.202128.2099230010518549663.davem@davemloft.net>
References: <20120609205316.GA5915@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, marc.c.dionne@gmail.com,
	tglx@linutronix.de, js@sig21.net, realnc@gmail.com,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab2FKDV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 23:21:29 -0400
In-Reply-To: <20120609205316.GA5915@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 9 Jun 2012 22:53:16 +0200

> While reworking the r8169 driver a few months ago to perform the
> smallest amount of work in the irq handler, I took care of avoiding
> any irq mask register operation in the slow work dedicated user
> context thread. The slow work thread scheduled an extra round of NAPI
> work which would ultimately set the irq mask register as required,
> thus keeping such irq mask operations in the NAPI handler.
> It would eventually race with the irq handler and delay NAPI execution
> for - assuming no further irq - a whole ksoftirqd period. Mildly a
> problem for rare link changes or corner case PCI events.
> 
> The race was always lost after the last bh disabling lock had been
> removed from the work thread and people started wondering where those
> pesky "NOHZ: local_softirq_pending 08" messages came from.
> 
> Actually the irq mask register _can_ be set up directly in the slow
> work thread.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Tested-by: Marc Dionne <marc.c.dionne@gmail.com>

Applied, thanks.
