From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 13:50:17 -0400
Message-ID: <20070504175017.GD8753@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Frederik Deweerdt <deweerdt@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:51253 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031458AbXEDRuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 13:50:21 -0400
Content-Disposition: inline
In-Reply-To: <20070504174456.GC8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 01:44:56PM -0400, Lennart Sorensen wrote:
> On Fri, May 04, 2007 at 11:40:09AM -0400, Lennart Sorensen wrote:
> > On Fri, May 04, 2007 at 05:34:38PM +0200, Frederik Deweerdt wrote:
> > > For the "what" part, see Documentation/lockdep-design.txt. You'll enable
> > > it by with SPINLOCK_DEBUG, indeed.
> > 
> > Well I hope to see it hit the BUG again soon then to see what it has to
> > say.
> 
> Well I didn't see anything for a while with SPINLOCK_DEBUG enabled
> (maybe I didn't wait long enough).  So I tried changing it to
> spin_lock_irqsave, and that didn't go well.  I got this as the result
> now:
> 
> onfiguring network interfaces...eth1: link up, 100Mbps, full-duplex
> BUG: spinlock recursion on CPU#0, ifconfig/962
>  lock: cf7a3304, .magic: dead4ead, .owner: ifconfig/962, .owner_cpu: 0
>  [<c0104024>] dump_stack+0x24/0x30
>  [<c01e3947>] _raw_spin_lock+0x137/0x140
>  [<c02981ec>] _spin_lock_irqsave+0x1c/0x30
>  [<d084eb86>] pcnet32_interrupt+0x216/0x290 [pcnet32]
>  [<c013b95d>] handle_IRQ_event+0x3d/0x70
>  [<c013ba2c>] __do_IRQ+0x9c/0x120
>  [<c0105025>] do_IRQ+0x25/0x60
>  [<c010316a>] common_interrupt+0x1a/0x20
>  [<c011927a>] __do_softirq+0x3a/0xa0
>  [<c011930d>] do_softirq+0x2d/0x30
>  [<c0119557>] irq_exit+0x37/0x40
>  [<c010502a>] do_IRQ+0x2a/0x60
>  [<c010316a>] common_interrupt+0x1a/0x20
>  [<c02983c0>] _spin_unlock_irqrestore+0x10/0x40
>  [<d08517ea>] pcnet32_open+0x27a/0x390 [pcnet32]
>  [<c02343e9>] dev_open+0x39/0x80
>  [<c0232b5a>] dev_change_flags+0xfa/0x130
>  [<c0277b7f>] devinet_ioctl+0x4ff/0x6f0
>  [<c0227b24>] sock_ioctl+0xf4/0x1f0
>  [<c017027c>] do_ioctl+0x2c/0x80
>  [<c0170322>] vfs_ioctl+0x52/0x2f0
>  [<c017062f>] sys_ioctl+0x6f/0x80
>  [<c0102f27>] syscall_call+0x7/0xb
>  [<b7eebd04>] 0xb7eebd04
> BUG: spinlock lockup on CPU#0, ifconfig/962, cf7a3304
>  [<c0104024>] dump_stack+0x24/0x30
>  [<c01e391f>] _raw_spin_lock+0x10f/0x140
>  [<c02981ec>] _spin_lock_irqsave+0x1c/0x30
>  [<d084eb86>] pcnet32_interrupt+0x216/0x290 [pcnet32]
>  [<c013b95d>] handle_IRQ_event+0x3d/0x70
>  [<c013ba2c>] __do_IRQ+0x9c/0x120
>  [<c0105025>] do_IRQ+0x25/0x60
>  [<c010316a>] common_interrupt+0x1a/0x20
>  [<c011927a>] __do_softirq+0x3a/0xa0
>  [<c011930d>] do_softirq+0x2d/0x30
>  [<c0119557>] irq_exit+0x37/0x40
>  [<c010502a>] do_IRQ+0x2a/0x60
>  [<c010316a>] common_interrupt+0x1a/0x20
>  [<c02983c0>] _spin_unlock_irqrestore+0x10/0x40
>  [<d08517ea>] pcnet32_open+0x27a/0x390 [pcnet32]
>  [<c02343e9>] dev_open+0x39/0x80
>  [<c0232b5a>] dev_change_flags+0xfa/0x130
>  [<c0277b7f>] devinet_ioctl+0x4ff/0x6f0
>  [<c0227b24>] sock_ioctl+0xf4/0x1f0
>  [<c017027c>] do_ioctl+0x2c/0x80
>  [<c0170322>] vfs_ioctl+0x52/0x2f0
>  [<c017062f>] sys_ioctl+0x6f/0x80
>  [<c0102f27>] syscall_call+0x7/0xb
>  [<b7eebd04>] 0xb7eebd04
> 
> Obviously that wasn't so good.

Nevermind.  I am obviously an idiot today placing spin_lock_irqsave both
in place of spin_lock and spin_unlock.  Yeah that will work well.  Now
to try with spin_lock_irqrestore or whatever it is called.

--
Len Sorensen
