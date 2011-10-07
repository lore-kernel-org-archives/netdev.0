From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e might_sleep warnings (3.1-rc9)
Date: Fri, 7 Oct 2011 09:43:01 -0700
Message-ID: <E0862362F1FF584BBCF7C4EA592A20C40D7D386B@orsmsx509.amr.corp.intel.com>
References: <20111007161430.GA2752@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14525 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329Ab1JGQnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:43:04 -0400
In-Reply-To: <20111007161430.GA2752@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Dave Jones
>Sent: Friday, October 07, 2011 9:15 AM
>To: netdev@vger.kernel.org
>Subject: e1000e might_sleep warnings (3.1-rc9)
>
>Just had this reported..
>
> > [20734.109233] Call Trace:
> > [20734.109242]  [<ffffffff8104f6b5>] __might_sleep+0x103/0x108
> > [20734.109249]  [<ffffffff8150363e>] mutex_lock_nested+0x25/0x45
> > [20734.109260]  [<ffffffffa023b8f7>] e1000_acquire_swflag_ich8lan+0x26/0x136
>[e1000e]
> > [20734.109271]  [<ffffffffa024a3af>] e1000e_update_stats+0x156/0x73e [e1000e]
> > [20734.109275]  [<ffffffff81504561>] ? _raw_spin_lock+0x71/0x79
> > [20734.109285]  [<ffffffffa024e658>] ? e1000_watchdog_task+0x3b1/0x5de
>[e1000e]
> > [20734.109294]  [<ffffffffa024e660>] e1000_watchdog_task+0x3b9/0x5de [e1000e]
> > [20734.109303]  [<ffffffffa024e2a7>] ? e1000_update_mng_vlan+0x68/0x68
>[e1000e]
> > [20734.109307]  [<ffffffff81075b21>] process_one_work+0x205/0x3e7
> > [20734.109310]  [<ffffffff81075a69>] ? process_one_work+0x14d/0x3e7
> > [20734.109315]  [<ffffffff8108cf0f>] ? lock_acquired+0x210/0x243
> > [20734.109320]  [<ffffffff810767cf>] worker_thread+0xda/0x15d
> > [20734.109323]  [<ffffffff810766f5>] ? manage_workers+0x176/0x176
> > [20734.109327]  [<ffffffff8107a195>] kthread+0xa8/0xb0
> > [20734.109332]  [<ffffffff8150dec4>] kernel_thread_helper+0x4/0x10
> > [20734.109336]  [<ffffffff81505334>] ? retint_restore_args+0x13/0x13
> > [20734.109340]  [<ffffffff8107a0ed>] ? __init_kthread_worker+0x5a/0x5a
> > [20734.109344]  [<ffffffff8150dec0>] ? gs_change+0x13/0x13
> > [20736.106653] BUG: sleeping function called from invalid context at
>kernel/mutex.c:271
> > [20736.106658] in_atomic(): 1, irqs_disabled(): 0, pid: 18071, name:
>kworker/0:1
> > [20736.106661] INFO: lockdep is turned off.
> > [20736.106664] Pid: 18071, comm: kworker/0:1 Not tainted 3.1.0-
>0.rc9.git0.0.fc17.x86_64 #1
> > [20736.106667] Call Trace:
> > [20736.106675]  [<ffffffff8104f6b5>] __might_sleep+0x103/0x108
> > [20736.106682]  [<ffffffff8150363e>] mutex_lock_nested+0x25/0x45
> > [20736.106693]  [<ffffffffa023b8f7>] e1000_acquire_swflag_ich8lan+0x26/0x136
>[e1000e]
> > [20736.106705]  [<ffffffffa024a3af>] e1000e_update_stats+0x156/0x73e [e1000e]
> > [20736.106709]  [<ffffffff81504561>] ? _raw_spin_lock+0x71/0x79
> > [20736.106719]  [<ffffffffa024e658>] ? e1000_watchdog_task+0x3b1/0x5de
>[e1000e]
> > [20736.106728]  [<ffffffffa024e660>] e1000_watchdog_task+0x3b9/0x5de [e1000e]
> > [20736.106737]  [<ffffffffa024e2a7>] ? e1000_update_mng_vlan+0x68/0x68
>[e1000e]
> > [20736.106741]  [<ffffffff81075b21>] process_one_work+0x205/0x3e7
> > [20736.106744]  [<ffffffff81075a69>] ? process_one_work+0x14d/0x3e7
> > [20736.106749]  [<ffffffff8108cf0f>] ? lock_acquired+0x210/0x243
> > [20736.106754]  [<ffffffff810767cf>] worker_thread+0xda/0x15d
> > [20736.106757]  [<ffffffff810766f5>] ? manage_workers+0x176/0x176
> > [20736.106761]  [<ffffffff8107a195>] kthread+0xa8/0xb0
> > [20736.106767]  [<ffffffff8150dec4>] kernel_thread_helper+0x4/0x10
> > [20736.106771]  [<ffffffff81505334>] ? retint_restore_args+0x13/0x13
> > [20736.106775]  [<ffffffff8107a0ed>] ? __init_kthread_worker+0x5a/0x5a
> > [20736.106779]  [<ffffffff8150dec0>] ? gs_change+0x13/0x13
> > [20738.104064] BUG: sleeping function called from invalid context at
>kernel/mutex.c:271
> > [20738.104070] in_atomic(): 1, irqs_disabled(): 0, pid: 18071, name:
>kworker/0:1
> > [20738.104073] INFO: lockdep is turned off.
> > [20738.104077] Pid: 18071, comm: kworker/0:1 Not tainted 3.1.0-
>0.rc9.git0.0.fc17.x86_64 #1
> > [20738.104079] Call Trace:
> > [20738.104088]  [<ffffffff8104f6b5>] __might_sleep+0x103/0x108
> > [20738.104096]  [<ffffffff8150363e>] mutex_lock_nested+0x25/0x45
> > [20738.104107]  [<ffffffffa023b8f7>] e1000_acquire_swflag_ich8lan+0x26/0x136
>[e1000e]
> > [20738.104118]  [<ffffffffa024a3af>] e1000e_update_stats+0x156/0x73e [e1000e]
> > [20738.104123]  [<ffffffff81504561>] ? _raw_spin_lock+0x71/0x79
> > [20738.104133]  [<ffffffffa024e658>] ? e1000_watchdog_task+0x3b1/0x5de
>[e1000e]
> > [20738.104142]  [<ffffffffa024e660>] e1000_watchdog_task+0x3b9/0x5de [e1000e]
> > [20738.104151]  [<ffffffffa024e2a7>] ? e1000_update_mng_vlan+0x68/0x68
>[e1000e]
> > [20738.104155]  [<ffffffff81075b21>] process_one_work+0x205/0x3e7
> > [20738.104158]  [<ffffffff81075a69>] ? process_one_work+0x14d/0x3e7
> > [20738.104162]  [<ffffffff8108cf0f>] ? lock_acquired+0x210/0x243
> > [20738.104167]  [<ffffffff810767cf>] worker_thread+0xda/0x15d
> > [20738.104170]  [<ffffffff810766f5>] ? manage_workers+0x176/0x176
> > [20738.104175]  [<ffffffff8107a195>] kthread+0xa8/0xb0
> > [20738.104180]  [<ffffffff8150dec4>] kernel_thread_helper+0x4/0x10
> > [20738.104184]  [<ffffffff81505334>] ? retint_restore_args+0x13/0x13
> > [20738.104188]  [<ffffffff8107a0ed>] ? __init_kthread_worker+0x5a/0x5a
> > [20738.104192]  [<ffffffff8150dec0>] ? gs_change+0x13/0x13
> >
> >
> >
> > On my x220 ThinnkPad.

Thanks, this has previously been reported, a fix is already in-house here
at Intel and should be pushed upstream soon.
