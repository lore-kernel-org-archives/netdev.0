From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net][bna] Separate handling of irq type flags
 variable from the irq_flags request_irq variable
Date: Fri, 15 Jul 2011 08:09:38 -0700 (PDT)
Message-ID: <20110715.080938.2283275421111060023.davem@davemloft.net>
References: <1310691632-22914-1-git-send-email-shyam_iyer@dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocade.com,
	huangj@brocade.com, ivecera@redhat.com, shyam_iyer@dell.com
To: shyam.iyer.t@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281Ab1GOPKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:10:47 -0400
In-Reply-To: <1310691632-22914-1-git-send-email-shyam_iyer@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shyam Iyer <shyam.iyer.t@gmail.com>
Date: Thu, 14 Jul 2011 21:00:32 -0400

> Commit 5f77898de17ff983ff0e2988b73a6bdf4b6f9f8b does not completely fix the problem of handling allocations with irqs disabled..
> The below patch on top of it fixes the problem completely.
> 
> Based on review by "Ivan Vecera" <ivecera@redhat.com>..
> "
> Small note, the root of the problem was that non-atomic allocation was requested with IRQs disabled. Your patch description does not contain wwhy were the IRQs disabled.
> 
> The function bnad_mbox_irq_alloc incorrectly uses 'flags' var for two different things, 1) to save current CPU flags and 2) for request_irq
> call.
> First the spin_lock_irqsave disables the IRQs and saves _all_ CPU flags (including one that enables/disables interrupts) to 'flags'. Then the 'flags' is overwritten by 0 or 0x80 (IRQF_SHARED). Finally the spin_unlock_irqrestore should restore saved flags, but these flags are now either 0x00 or 0x80. The interrupt bit value in flags register on x86 arch is 0x100.
> This means that the interrupt bit is zero (IRQs disabled) after spin_unlock_irqrestore so the request_irq function is called with disabled interrupts.
> "
> 
> Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>

Applied.
