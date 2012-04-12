From: "Matt Renzelmann" <mjr@cs.wisc.edu>
Subject: RE: [PATCH] ks8851: Cancel any pending IRQ work
Date: Thu, 12 Apr 2012 15:34:26 -0500
Message-ID: <005701cd18eb$aaa0ab90$ffe202b0$@cs.wisc.edu>
References: <1334249091-7605-1-git-send-email-mjr@cs.wisc.edu> <4F8738EB.2060806@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ben@simtec.co.uk>,
	<netdev@vger.kernel.org>, "Matt Renzelmann" <mjr@cs.wisc.edu>
To: "'Stephen Boyd'" <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:47770 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756068Ab2DLUfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 16:35:15 -0400
In-Reply-To: <4F8738EB.2060806@codeaurora.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Is this actually solving anything? Presumably cancel_work_sync() could
> run and then another spurious interrupt could come in after that
> function returns and we would have the same problem again. We should
> probably free the irq before unregistering the netdev so that
> ks8851_net_stop() would run after the interrupt is no longer registered,
> and the flush_work() in there would finish the last work. But then we
> have a problem where we're enabling the irq in the irq_work callback
> after the irq has been freed. Ugh.
> 
> I also see a potential deadlock in ks8851_net_stop(). ks8851_net_stop()
> holds the ks->lock while calling flush_work() which could deadlock if an
> interrupt comes and schedules an irq_work between the time
> ks8851_net_stop() grabs the mutex and calls flush_work().
> 

I agree on all counts -- the patch is buggy, though it does at least "shrink"
the window of vulnerability.  Frankly, I don't believe I'm qualified to write an
appropriate patch for this driver, at least without spending considerably more
time on it.

FWIW, I found this problem with a new driver-testing tool we've developed called
SymDrive, and my goal is primarily to determine if the bug is real or not.  The
tool is imperfect and we are trying to validate its operation.

That said, if there is an issue here, and we can come up with an appropriate
fix, then I'd be happy to write a patch for it.
