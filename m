From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fwd: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 12:49:17 +0800
Message-ID: <20110217044917.GA2653@cr0.nay.redhat.com>
References: <AANLkTimj+_8cBz0gcEyF1889xK2HdF4SQDSK8DiY-4Gs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51731 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab1BQEtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 23:49:33 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimj+_8cBz0gcEyF1889xK2HdF4SQDSK8DiY-4Gs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 11:39:22AM +0800, Cypher Wu wrote:
>---------- Forwarded message ----------
>From: Cypher Wu <cypher.w@gmail.com>
>Date: Wed, Feb 16, 2011 at 5:58 PM
>Subject: GMP and rwlock: Dead ocurred again on TILEPro
>To: linux-kernel@vger.kernel.org
>
>
>The rwlock and spinlock of TILEPro platform use TNS instruction to
>test the value of lock, but if interrupt is not masked, read_lock()
>have another chance to deadlock while read_lock() called in bh of
>interrupt.
>


In this case, you should call read_lock_bh() instead of read_lock().


> frame 0: 0xfd3bfbe0 dump_stack+0x0/0x20 (sp 0xe4b5f9d8)
> frame 1: 0xfd3c0b50 __raw_read_lock_slow.cold+0x50/0x90 (sp 0xe4b5f9d8)
> frame 2: 0xfd184a58 igmpv3_send_cr+0x60/0x440 (sp 0xe4b5f9f0)
> frame 3: 0xfd3bd928 igmp_ifc_timer_expire+0x30/0x90 (sp 0xe4b5fa20)
> frame 4: 0xfd047698 run_timer_softirq+0x258/0x3c8 (sp 0xe4b5fa30)
> frame 5: 0xfd0563f8 __do_softirq+0x138/0x220 (sp 0xe4b5fa70)
> frame 6: 0xfd097d48 do_softirq+0x88/0x110 (sp 0xe4b5fa98)
> frame 7: 0xfd1871f8 irq_exit+0xf8/0x120 (sp 0xe4b5faa8)
> frame 8: 0xfd1afda0 do_timer_interrupt+0xa0/0xf8 (sp 0xe4b5fab0)
> frame 9: 0xfd187b98 handle_interrupt+0x2d8/0x2e0 (sp 0xe4b5fac0)
> <interrupt 25 while in kernel mode>
> frame 10: 0xfd0241c8 _read_lock+0x8/0x40 (sp 0xe4b5fc38)
> frame 11: 0xfd1bb008 ip_mc_del_src+0xc8/0x378 (sp 0xe4b5fc40)
> frame 12: 0xfd2681e8 ip_mc_leave_group+0xf8/0x1e0 (sp 0xe4b5fc70)
> frame 13: 0xfd0a4d70 do_ip_setsockopt+0xe48/0x1560 (sp 0xe4b5fc90)
> frame 14: 0xfd2b4168 sys_setsockopt+0x150/0x170 (sp 0xe4b5fe98)
> frame 15: 0xfd14e550 handle_syscall+0x2d0/0x320 (sp 0xe4b5fec0)
> <syscall while in user mode>
> frame 16: 0x3342a0 (sp 0xbfddfb00)
> frame 17: 0x16130 (sp 0xbfddfb08)
> frame 18: 0x16640 (sp 0xbfddfb38)
> frame 19: 0x16ee8 (sp 0xbfddfc58)
> frame 20: 0x345a08 (sp 0xbfddfc90)
> frame 21: 0x10218 (sp 0xbfddfe48)
>Stack dump complete
>
>I don't know the clear definition of rwlock & spinlock in Linux, but
>the implementation of other platforms
>like x86, PowerPC, ARM don't have that issue. The use of TNS cause a
>race condition between system
>call and interrupt.
>

Have you turned CONFIG_LOCKDEP on?

I think Eric already converted that rwlock into RCU lock, thus
this problem should disappear. Could you try a new kernel?

Thanks.
