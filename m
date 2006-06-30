From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 8/9] pcnet32: NAPI implementation.
Date: Fri, 30 Jun 2006 09:15:51 +0200
Message-ID: <20060630071551.GA26908@electric-eye.fr.zoreil.com>
References: <20060629205551.GA22031@us.ibm.com> <20060629222438.GB8122@electric-eye.fr.zoreil.com> <20060629234104.GA22583@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:61599 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751194AbWF3HUI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 03:20:08 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060629234104.GA22583@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry <brazilnut@us.ibm.com> :
[...]
> > No need to save/restore (it's true in pcnet32_{get_regs/suspend} too).
> 
> This lock is taken by the interrupt handler and my reading of
> spinlocks.txt says I do need to use spin_lock_irqsave unless I
> misunderstand.  The only spin_lock() is in the interrupt handler itself,
> all others are spin_lock_irqsave.

The poll() function is issued in an irq enabled context. The state to be
saved (in flags) is known thus the code can simply disable and enable the
irq.

[...]
> > Insert mmiowb():
> 
> Is this required in addition to the two outw() in write_csr?  There are
> rmb() and wmb() in the places that need them, but no mmiowb() anywhere.
> What are the factors for when mmiowb needs to be inserted?

They are explained in Documentation/memory-barriers.txt.

I doubt that many user would be hurt if the mmiowb() are not added :o)

-- 
Ueimor
