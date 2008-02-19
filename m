From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 18 Feb 2008 20:29:34 -0800 (PST)
Message-ID: <20080218.202934.79548477.davem@davemloft.net>
References: <47B17BCD.2070903@katalix.com>
	<20080214130016.GA2583@ff.dom.local>
	<47BA0214.40703@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51572
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751645AbYBSE25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 23:28:57 -0500
In-Reply-To: <47BA0214.40703@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Mon, 18 Feb 2008 22:09:24 +0000

> Here's a new version of the patch. The patch avoids disabling irqs
> and fixes the sk_dst_get() usage that DaveM mentioned. But even with
> this patch, lockdep still complains if hundreds of ppp sessions are
> inserted into a tunnel as rapidly as possible (lockdep trace is
> below). I can stop these errors by wrapping the call to ppp_input()
> in pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is
> a better fix?

Firstly, let's fix one thing at a time.  Leave the sk_dst_get()
thing alone until we can prove that it's part of the lockdep
traces.

Next, I can't see why ppp_input() needs to be invoked with
interrupts disabled.  There are many other things that invoke
that in software interrupt context, such as pppoe.

Please provide the lockdep traces without the ppp_input() IRQ
disabling so this can be properly analyzed.
