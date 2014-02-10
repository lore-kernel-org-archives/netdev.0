From: Dave Jones <davej@redhat.com>
Subject: irda: BUG: looking up invalid subclass: 4294967295
Date: Mon, 10 Feb 2014 16:31:26 -0500
Message-ID: <20140210213126.GA26078@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291AbaBJVb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 16:31:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this irda being crap, or some weird lockdep corner case ?

(no idea what the W taint was, some unrelated spew pushed it out
 of the dmesg buffer before it got chance to hit the log)

	Dave

BUG: looking up invalid subclass: 4294967295
turning off the locking correctness validator.
CPU: 0 PID: 1965 Comm: trinity-main Tainted: G        W    3.14.0-rc1+ #108
 00000000ffffffff 00000000a8765326 ffff880205ee7c40 ffffffff9872ae0a
 00000000ffffffff ffff880205ee7c58 ffffffff9872732c ffff880084069730
 ffff880205ee7cd0 ffffffff980c10e2 000000010016000f 00000000ffffffff
Call Trace:
 [<ffffffff9872ae0a>] dump_stack+0x4e/0x7a
 [<ffffffff9872732c>] look_up_lock_class.part.18+0x2f/0x34
 [<ffffffff980c10e2>] __lock_acquire.isra.28+0x722/0xa50
 [<ffffffff9873a01b>] ? preempt_count_sub+0x6b/0xf0
 [<ffffffff980c1b6d>] lock_acquire+0x8d/0x120
 [<ffffffffc05438f2>] ? hashbin_delete+0xf2/0x100 [irda]
 [<ffffffffc0545e30>] ? irias_delete_value+0x30/0x30 [irda]
 [<ffffffff987357fc>] _raw_spin_lock_irqsave_nested+0x4c/0x70
 [<ffffffffc05438f2>] ? hashbin_delete+0xf2/0x100 [irda]
 [<ffffffffc05438f2>] hashbin_delete+0xf2/0x100 [irda]
 [<ffffffffc0546266>] __irias_delete_object+0x26/0x40 [irda]
 [<ffffffffc05462a4>] irias_delete_object+0x24/0x30 [irda]
 [<ffffffffc05489a5>] irda_release+0x65/0x160 [irda]
 [<ffffffff985fa59f>] sock_release+0x1f/0x80
 [<ffffffff985fa612>] sock_close+0x12/0x20
 [<ffffffff981bf0fa>] __fput+0xea/0x2c0
 [<ffffffff981bf31e>] ____fput+0xe/0x10
 [<ffffffff98090924>] task_work_run+0xb4/0xe0
 [<ffffffff9806e791>] do_exit+0x2e1/0xb50
 [<ffffffff980ab791>] ? vtime_account_user+0x91/0xa0
 [<ffffffff9814f69b>] ? context_tracking_user_exit+0x9b/0x100
 [<ffffffff9806ffec>] do_group_exit+0x4c/0xc0
 [<ffffffff98070074>] SyS_exit_group+0x14/0x20
 [<ffffffff9873e66a>] tracesys+0xd4/0xd9
