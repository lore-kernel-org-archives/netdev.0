From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Fw: [Bug 107141] New: [1177853.192071] INFO: task
 accel-pppd:24263 blocked for more than 120 seconds.
Date: Thu, 12 Nov 2015 14:51:45 +0100
Message-ID: <20151112135145.GA3162@alphalink.fr>
References: <20151111085715.337c6958@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: pstaszewski@artcom.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42234 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753118AbbKLNv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 08:51:56 -0500
Content-Disposition: inline
In-Reply-To: <20151111085715.337c6958@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 08:57:15AM -0800, Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Wed, 4 Nov 2015 10:46:56 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 107141] New: [1177853.192071] INFO: task accel-pppd:24263 blocked for more than 120 seconds.
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=107141
> 
>             Bug ID: 107141
>            Summary: [1177853.192071] INFO: task accel-pppd:24263 blocked
>                     for more than 120 seconds.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.1.12 , 4.2.0 , 4.3
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: pstaszewski@artcom.pl
>         Regression: No
> 
> Latest checked kernel where no problem exist:
> 3.13.0
> 
> 
> 
> On any kernel >4.0 I have always same problem as below:
> 
[...]

> [1177853.192196] INFO: task accel-pppd:10821 blocked for more than 120 seconds.
> [1177853.192196]       Not tainted 4.2.0 #1
> [1177853.192197] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> this message.
> [1177853.192198] accel-pppd      D ffff88021fd14680     0 10821      1
> 0x00000000
> [1177853.192199]  ffff8800d771fd08 0000000000000082 ffff8800d771fcd8
> ffff8802161c0000
> [1177853.192201]  ffff8800d7720000 ffff8801fe650bc0 ffff8800d771fce8
> ffff8800d7720000
> [1177853.192202]  ffff8801fe650bc0 ffffffff81a9d264 ffffffff81a9d268
> 00000000ffffffff
> [1177853.192203] Call Trace:
> [1177853.192205]  [<ffffffff815ceb86>] schedule+0x71/0x80
> [1177853.192207]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
> [1177853.192208]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
> [1177853.192210]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
> [1177853.192212]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
> [1177853.192214]  [<ffffffff814c14b2>] register_netdev+0x11/0x27
> [1177853.192215]  [<ffffffff8141ba62>] ppp_ioctl+0x2ee/0xb9d
> [1177853.192218]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
> [1177853.192219]  [<ffffffff815d0da9>] ? _raw_spin_lock+0x9/0xb
> [1177853.192221]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
> [1177853.192222]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
> [1177853.192224]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a

[...]

> [1177853.192306] INFO: task accel-pppd:6838 blocked for more than 120 seconds.
> [1177853.192307]       Not tainted 4.2.0 #1
> [1177853.192308] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> this message.
> [1177853.192308] accel-pppd      D ffff88021fc14680     0  6838      1
> 0x00000000
> [1177853.192310]  ffff8800c5ca7d08 0000000000000082 00000000000380ef
> ffffffff81a114c0
> [1177853.192311]  000000000f48ff3a ffff8800d76c3ac0 0000000000000000
> ffff8800c5ca8000
> [1177853.192313]  ffff8800d76c3ac0 ffff880215e3cdac ffff880215e3cdb0
> 00000000ffffffff
> [1177853.192314] Call Trace:
> [1177853.192316]  [<ffffffff815ceb86>] schedule+0x71/0x80
> [1177853.192317]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
> [1177853.192319]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
> [1177853.192320]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
> [1177853.192322]  [<ffffffff8141ab77>] ppp_dev_uninit+0x62/0xae
> [1177853.192324]  [<ffffffff814bd4e2>] rollback_registered_many+0x19e/0x252
> [1177853.192325]  [<ffffffff814bd600>] rollback_registered+0x29/0x38
> [1177853.192327]  [<ffffffff814bd679>] unregister_netdevice_queue+0x6a/0x77
> [1177853.192328]  [<ffffffff8141b740>] ppp_release+0x3f/0x73
> [1177853.192330]  [<ffffffff81110a49>] __fput+0xdf/0x184
> [1177853.192332]  [<ffffffff81110b1e>] ____fput+0x9/0xb
> [1177853.192335]  [<ffffffff8104fac7>] task_work_run+0x7b/0x94
> [1177853.192336]  [<ffffffff81003615>] do_notify_resume+0x40/0x44
> [1177853.192338]  [<ffffffff815d1182>] int_signal+0x12/0x17

This should be fixed by 58a89ecaca53 ("ppp: fix lockdep splat in
ppp_dev_uninit()").

Only Linux 4.2 is impacted (not counting -rcX versions). The fix has
been integrated into the -stable tree with Linux 4.2.3.

If lockups occur on Linux 4.1.12 or Linux 4.3, they most likely have
another origin.
