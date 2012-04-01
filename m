From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sun, 1 Apr 2012 18:38:33 +0200
Message-ID: <20120401163833.GA29697@redhat.com>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com> <1333227549.2325.4051.camel@edumazet-glaptop> <20120331213423.GA21219@redhat.com> <CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com> <CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414Ab2DARSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2012 13:18:12 -0400
Content-Disposition: inline
In-Reply-To: <CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01, Sasha Levin wrote:
>
> >> It would be nice to know what sysrq-t says, in particular the trace
> >> of khelper thread is interesting.
> >
> > Sure, I'll get one when it happens again.
>
> So here's the stack of the usermode thread:

Great, thanks, this is even better than khelper's trace,

> [  336.614015]  [<ffffffff826a8e54>] schedule+0x24/0x70
> [  336.614015]  [<ffffffff825fd66d>] p9_client_rpc+0x13d/0x360
> [  336.614015]  [<ffffffff810d7850>] ? wake_up_bit+0x40/0x40
> [  336.614015]  [<ffffffff810e3671>] ? get_parent_ip+0x11/0x50
> [  336.614015]  [<ffffffff810e399d>] ? sub_preempt_count+0x9d/0xd0
> [  336.614015]  [<ffffffff825ff5ff>] p9_client_walk+0x8f/0x220
> [  336.614015]  [<ffffffff815a8e3b>] v9fs_vfs_lookup+0xab/0x1c0
> [  336.614015]  [<ffffffff811ee0c0>] d_alloc_and_lookup+0x40/0x80
> [  336.614015]  [<ffffffff811fdea0>] ? d_lookup+0x30/0x50
> [  336.614015]  [<ffffffff811f0aea>] do_lookup+0x28a/0x3b0
> [  336.614015]  [<ffffffff817c9117>] ? security_inode_permission+0x17/0x20
> [  336.614015]  [<ffffffff811f1c07>] link_path_walk+0x167/0x420
> [  336.614015]  [<ffffffff811ee630>] ? generic_readlink+0xb0/0xb0
> [  336.614015]  [<ffffffff81896d88>] ? __raw_spin_lock_init+0x38/0x70
> [  336.614015]  [<ffffffff811f24da>] path_openat+0xba/0x500
> [  336.614015]  [<ffffffff81057253>] ? sched_clock+0x13/0x20
> [  336.614015]  [<ffffffff810ed805>] ? sched_clock_local+0x25/0x90
> [  336.614015]  [<ffffffff810ed940>] ? sched_clock_cpu+0xd0/0x120
> [  336.614015]  [<ffffffff811f2a34>] do_filp_open+0x44/0xa0
> [  336.614015]  [<ffffffff81119acd>] ? __lock_release+0x8d/0x1d0
> [  336.614015]  [<ffffffff810e3671>] ? get_parent_ip+0x11/0x50
> [  336.614015]  [<ffffffff810e399d>] ? sub_preempt_count+0x9d/0xd0
> [  336.614015]  [<ffffffff826aa7f0>] ? _raw_spin_unlock+0x30/0x60
> [  336.614015]  [<ffffffff811ea74d>] open_exec+0x2d/0xf0
> [  336.614015]  [<ffffffff811eb888>] do_execve_common+0x128/0x320
> [  336.614015]  [<ffffffff811ebb05>] do_execve+0x35/0x40
> [  336.614015]  [<ffffffff810589e5>] sys_execve+0x45/0x70
> [  336.614015]  [<ffffffff826acc28>] kernel_execve+0x68/0xd0
> [  336.614015]  [<ffffffff810cd6a6>] ? ____call_usermodehelper+0xf6/0x130
> [  336.614015]  [<ffffffff810cd6f9>] call_helper+0x19/0x20
> [  336.614015]  [<ffffffff826acbb4>] kernel_thread_helper+0x4/0x10
> [  336.614015]  [<ffffffff810e3f80>] ? finish_task_switch+0x80/0x110
> [  336.614015]  [<ffffffff826aaeb4>] ? retint_restore_args+0x13/0x13
> [  336.614015]  [<ffffffff810cd6e0>] ? ____call_usermodehelper+0x130/0x130
> [  336.614015]  [<ffffffff826acbb0>] ? gs_change+0x13/0x13
>
> While it seems that 9p is the culprit, I have to point out that this
> bug is easily reproducible, and it happens each time due to a
> call_usermode_helper() call. Other than that 9p behaves perfectly and
> I'd assume that I'd be seeing other things break besides
> call_usermode_helper() related ones.

Of course I do not know what happens, but at least this obviously
explains why UMH_WAIT_EXEC hangs, I think call_usermodehelper_exec()
itself is innocent.

Oleg.
