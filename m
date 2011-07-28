From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 40132] New: kernel BUG at mm/slab.c:501, when in kfree
 from ipv4_frags_exit_net
Date: Thu, 28 Jul 2011 08:35:26 -0700
Message-ID: <20110728083526.6f55bee9@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46341 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753951Ab1G1PfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 11:35:20 -0400
Received: from nehalam.ftrdhcpuser.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p6SFZDQt002744
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 08:35:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 26 Jul 2011 13:49:14 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 40132] New: kernel BUG at mm/slab.c:501, when in kfree from ipv4_frags_exit_net


https://bugzilla.kernel.org/show_bug.cgi?id=40132

           Summary: kernel BUG at mm/slab.c:501, when in kfree from
                    ipv4_frags_exit_net
           Product: Networking
           Version: 2.5
    Kernel Version: 3.0.0-03370-gb6844e8
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: baryluk@smp.if.uj.edu.pl
        Regression: No


Created an attachment (id=66702)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=66702)
Kernel config

Happens 16.3% of times. gcc 4.4.5. i386. Debian GNU/Linux stable (squeeze).

It is probably one of the most rearly tested cleanup routines in kernel. I
discovered it by incident because of the bug in kdevtmpfs initialization.

[    9.802917] BUG: unable to handle kernel paging request at 61203a73
[    9.803237] IP: [<c115ed37>] path_init+0xc7/0x3b0
[    9.803584] *pdpt = 0000000000000000 *pde = 0000000000000000 
[    9.803940] Oops: 0000 [#1] PREEMPT SMP 
[    9.804223] Modules linked in:
[    9.804434] 
[    9.804615] Pid: 13, comm: kdevtmpfs Not tainted 3.0.0-t43-03370-gb6844e8
#22 Bochs Bochs
[    9.804980] EIP: 0060:[<c115ed37>] EFLAGS: 00000246 CPU: 0
[    9.805223] EIP is at path_init+0xc7/0x3b0
[    9.805402] EAX: ffffff9c EBX: c78e1e90 ECX: 00000050 EDX: 00001050
[    9.805643] ESI: 61203a73 EDI: 61203a73 EBP: c78e1e20 ESP: c78e1df8
[    9.805888]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    9.806119] Process kdevtmpfs (pid: 13, ti=c78e0000 task=c78de1a0
task.ti=c78e0000)
[    9.806407] Stack:
[    9.806528]  c78e1e00 00000e44 00000000 c78e1e14 00000e44 c78e1e14 c109446d
c78e1e90
[    9.806998]  c78e1f44 61203a73 c78e1e68 c115ff21 c78e1e90 c78e1e58 c17a9da7
c78ba0e0
[    9.807432]  c78e1e48 00000006 00000050 c78de1a0 c78e1e58 c10985c1 c7d47d00
c1a787e0
[    9.807882] Call Trace:
[    9.808047]  [<c109446d>] ? put_lock_stats+0xd/0x30
[    9.808263]  [<c115ff21>] path_lookupat+0x31/0x5d0
[    9.808469]  [<c17a9da7>] ? _raw_spin_unlock_irq+0x27/0x60
[    9.808697]  [<c10985c1>] ? trace_hardirqs_on_caller+0x61/0xa0
[    9.808938]  [<c11604ec>] do_path_lookup+0x2c/0xb0
[    9.809150]  [<c1160656>] kern_path_create+0x26/0xe0
[    9.809360]  [<c17a69aa>] ? schedule+0x3a/0x770
[    9.809562]  [<c1094482>] ? put_lock_stats+0x22/0x30
[    9.809776]  [<c1413531>] handle_create+0x31/0x100
[    9.809985]  [<c17a7462>] ? preempt_schedule+0x32/0x50
[    9.810146]  [<c17a9d74>] ? _raw_spin_unlock_irqrestore+0x74/0x80
[    9.810146]  [<c104749b>] ? complete+0x4b/0x60
[    9.810146]  [<c14139b5>] devtmpfsd+0xf5/0x150
[    9.810146]  [<c14138c0>] ? handle_remove+0x200/0x200
[    9.810146]  [<c107dac4>] kthread+0x74/0x80
[    9.810146]  [<c107da50>] ? __init_kthread_worker+0x60/0x60
[    9.810146]  [<c17b0e7a>] kernel_thread_helper+0x6/0x10
[    9.810146] Code: f3 ff 8b 53 04 8b 42 04 a8 01 0f 85 b5 02 00 00 89 43 24
31 ff 89 f8 8b 5d f4 8b 75 f8 8b 7d fc 89 ec 5d c3 c7 43 14 00 00 00 00 
[    9.810146]  3e 2f 0f 84 c8 00 00 00 83 f8 9c 74 5b 8d 55 f0 bf f7 ff ff 
[    9.810146] EIP: [<c115ed37>] path_init+0xc7/0x3b0 SS:ESP 0068:c78e1df8
[    9.810146] CR2: 0000000061203a73
[    9.815606] kobject: 'hpet' (c7b77220): kobject_add_internal: parent:
'drivers', set: 'drivers'
[    9.816880] kobject: 'hpet' (c7b77220): kobject_uevent_env
[    9.817122] kobject: 'hpet' (c7b77220): fill_kobj_path: path =
'/bus/acpi/drivers/hpet'
[    9.818518] kobject: 'nvram' (c7b6dc08): kobject_add_internal: parent:
'misc', set: 'devices'
[    9.819257] ---[ end trace b8a3675a10c16a9a ]---
[    9.819558] kdevtmpfs used greatest stack depth: 6172 bytes left
[    9.872251] kobject: 'rx-0' (c798c9a8): kobject_cleanup
[    9.872471] kobject: 'rx-0' (c798c9a8): auto cleanup 'remove' event
[    9.872705] kobject: 'rx-0' (c798c9a8): kobject_uevent_env
[    9.872930] kobject: 'rx-0' (c798c9a8): fill_kobj_path: path =
'/devices/virtual/net/lo/queues/rx-0'
[    9.874037] kobject: 'rx-0' (c798c9a8): auto cleanup kobject_del
[    9.874359] kobject: 'rx-0' (c798c9a8): calling ktype release
[    9.874608] kobject: 'rx-0': free name
[    9.874795] kobject: 'tx-0' (c798b950): kobject_cleanup
[    9.874996] kobject: 'tx-0' (c798b950): auto cleanup 'remove' event
[    9.875227] kobject: 'tx-0' (c798b950): kobject_uevent_env
[    9.875469] kobject: 'tx-0' (c798b950): fill_kobj_path: path =
'/devices/virtual/net/lo/queues/tx-0'
[    9.876721] kobject: 'tx-0' (c798b950): auto cleanup kobject_del
[    9.880057] kobject: 'tx-0' (c798b950): calling ktype release
[    9.881695] kobject: 'tx-0': free name
[    9.881878] kobject: 'queues' (c798b870): kobject_cleanup
[    9.882082] kobject: 'queues' (c798b870): auto cleanup kobject_del
[    9.882349] kobject: 'queues' (c798b870): calling ktype release
[    9.882579] kobject: 'queues' (c798b870): kset_release
[    9.882789] kobject: 'queues': free name
[    9.884069] kobject: 'lo' (c7996acc): kobject_uevent_env
[    9.884287] kobject: 'lo' (c7996acc): fill_kobj_path: path =
'/devices/virtual/net/lo'
[    9.885368] kobject: 'net' (c798c960): kobject_cleanup
[    9.885573] kobject: 'net' (c798c960): auto cleanup kobject_del
[    9.885834] kobject: 'net' (c798c960): calling ktype release
[    9.886061] kobject: 'net': free name
[    9.892232] kobject: 'lo' (c7996acc): kobject_cleanup
[    9.892552] kobject: 'lo' (c7996acc): calling ktype release
[    9.892914] kobject: 'lo': free name
[    9.893865] ------------[ cut here ]------------
[    9.894234] WARNING: at fs/proc/generic.c:850
remove_proc_entry+0x26a/0x270()
[    9.894548] Hardware name: Bochs
[    9.894730] remove_proc_entry: removing non-empty directory 'net/rpc',
leaking at least 'nfs'
[    9.895070] Modules linked in:
[    9.895384] Pid: 14, comm: kworker/u:1 Tainted: G      D    
3.0.0-t43-03370-gb6844e8 #22
[    9.895733] Call Trace:
[    9.895943]  [<c105bb52>] warn_slowpath_common+0x72/0xa0
[    9.896205]  [<c11ab88a>] ? remove_proc_entry+0x26a/0x270
[    9.896450]  [<c11ab88a>] ? remove_proc_entry+0x26a/0x270
[    9.896705]  [<c105bc23>] warn_slowpath_fmt+0x33/0x40
[    9.896943]  [<c11ab88a>] remove_proc_entry+0x26a/0x270
[    9.897233]  [<c1140265>] ? kfree+0xc5/0x280
[    9.897457]  [<c16fa2a7>] ? ip_map_cache_destroy+0x97/0xb0
[    9.897708]  [<c1098579>] ? trace_hardirqs_on_caller+0x19/0xa0
[    9.897966]  [<c109860b>] ? trace_hardirqs_on+0xb/0x10
[    9.898206]  [<c17a9cdc>] ? _raw_spin_unlock+0x2c/0x50
[    9.898446]  [<c17006cd>] ? sunrpc_destroy_cache_detail+0x6d/0xc0
[    9.898719]  [<c16fec48>] ? remove_cache_proc_entries+0x68/0xf0
[    9.898993]  [<c1704b54>] rpc_proc_exit+0x24/0x40
[    9.899217]  [<c16fe0a7>] sunrpc_exit_net+0x17/0x20
[    9.899450]  [<c159eaef>] ops_exit_list+0x2f/0x50
[    9.899676]  [<c159f369>] cleanup_net+0xd9/0x170
[    9.899905]  [<c10778d8>] process_one_work+0x1d8/0x4c0
[    9.905162]  [<c107785c>] ? process_one_work+0x15c/0x4c0
[    9.905439]  [<c159f290>] ? register_pernet_subsys+0x40/0x40
[    9.905678]  [<c1078b70>] worker_thread+0x140/0x3a0
[    9.905886]  [<c17a7462>] ? preempt_schedule+0x32/0x50
[    9.906104]  [<c1078a30>] ? manage_workers+0x110/0x110
[    9.906317]  [<c107dac4>] kthread+0x74/0x80
[    9.906509]  [<c107da50>] ? __init_kthread_worker+0x60/0x60
[    9.906740]  [<c17b0e7a>] kernel_thread_helper+0x6/0x10
[    9.906981] ---[ end trace b8a3675a10c16a9b ]---
[    9.907540] ------------[ cut here ]------------
[    9.907738] kernel BUG at mm/slab.c:501!
[    9.907909] invalid opcode: 0000 [#2] PREEMPT SMP 
[    9.908150] Modules linked in:
[    9.908296] 
[    9.908385] Pid: 14, comm: kworker/u:1 Tainted: G      D W  
3.0.0-t43-03370-gb6844e8 #22 Bochs Bochs
[    9.908755] EIP: 0060:[<c1140383>] EFLAGS: 00000046 CPU: 0
[    9.908971] EIP is at kfree+0x1e3/0x280
[    9.909136] EAX: 40000400 EBX: c7f31920 ECX: c11401df EDX: c87fd000
[    9.909370] ESI: c1ac9b60 EDI: c15f5f39 EBP: c78edebc ESP: c78ede90
[    9.909604]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    9.909813] Process kworker/u:1 (pid: 14, ti=c78ec000 task=c78ea1c0
task.ti=c78ec000)
[    9.910117] Stack:
[    9.910220]  c7abdbc0 c7a234e0 c251b2c0 00000282 c780e800 00000286 c19fcd82
c1ac9b60
[    9.910477]  c251b2c0 c1ac9b60 c78edee8 c78edecc c15f5f39 c1ac9b40 c251b2c0
c78edee0
[    9.910477]  c159eaef c78edee8 c1ac9b40 c1ac3428 c78edf04 c159f369 c251b300
c251b300
[    9.910477] Call Trace:
[    9.910477]  [<c15f5f39>] ipv4_frags_exit_net+0x29/0x50
[    9.910477]  [<c159eaef>] ops_exit_list+0x2f/0x50
[    9.910477]  [<c159f369>] cleanup_net+0xd9/0x170
[    9.910477]  [<c10778d8>] process_one_work+0x1d8/0x4c0
[    9.910477]  [<c107785c>] ? process_one_work+0x15c/0x4c0
[    9.910477]  [<c159f290>] ? register_pernet_subsys+0x40/0x40
[    9.910477]  [<c1078b70>] worker_thread+0x140/0x3a0
[    9.910477]  [<c17a7462>] ? preempt_schedule+0x32/0x50
[    9.910477]  [<c1078a30>] ? manage_workers+0x110/0x110
[    9.910477]  [<c107dac4>] kthread+0x74/0x80
[    9.910477]  [<c107da50>] ? __init_kthread_worker+0x60/0x60
[    9.910477]  [<c17b0e7a>] kernel_thread_helper+0x6/0x10
[    9.910477] Code: e9 fa fe ff ff 8b 55 ec 89 f1 89 d8 83 c2 38 89 55 e4 c7
04 24 00 00 00 00 e8 da fc ff ff 89 f1 c1 e1 02 89 75 e0 89 4d dc eb 9f <0f> 0b
eb fe 8b 5b 0c e9 86 fe ff ff 8b 5b 0c e9 6e fe ff ff 89 
[    9.910477] EIP: [<c1140383>] kfree+0x1e3/0x280 SS:ESP 0068:c78ede90
[    9.910477] ---[ end trace b8a3675a10c16a9c ]---
[    9.918123] BUG: unable to handle kernel paging request at fffffffc
[    9.918410] IP: [<c107d61f>] kthread_data+0xf/0x20
[    9.918630] *pdpt = 0000000001ce7001 *pde = 0000000001cec067 *pte =
0000000000000000 
[    9.918990] Oops: 0000 [#3] PREEMPT SMP 
[    9.919197] Modules linked in:
[    9.919339] 
[    9.919426] Pid: 14, comm: kworker/u:1 Tainted: G      D W  
3.0.0-t43-03370-gb6844e8 #22 Bochs Bochs
[    9.919791] EIP: 0060:[<c107d61f>] EFLAGS: 00000002 CPU: 0
[    9.920005] EIP is at kthread_data+0xf/0x20
[    9.920206] EAX: 00000000 EBX: 00000000 ECX: c1cddd00 EDX: 00000000
[    9.920468] ESI: 00000000 EDI: c1cddd00 EBP: c78edcac ESP: c78edca0
[    9.920718]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    9.920942] Process kworker/u:1 (pid: 14, ti=c78ec000 task=c78ea1c0
task.ti=c78ec000)
[    9.921247] Stack:
[    9.921348]  c10767b1 c78ea1c0 00000000 c78edd3c c17a6ef9 00000000 c1a6cb90
c2426f80
[    9.921822]  c10cc943 c78edcec 00000004 c1cddd00 c1cddd00 c1cddd00 c7d433a0
c78edce4
[    9.922295]  c7d47d00 c78ea1c0 00000202 00000001 00000202 c78ea1c0 c78ea1c0
00000001
[    9.922878] Call Trace:
[    9.923018]  [<c10767b1>] ? wq_worker_sleeping+0x11/0x80
[    9.923257]  [<c17a6ef9>] schedule+0x589/0x770
[    9.923466]  [<c10cc943>] ? __call_rcu+0xd3/0x190
[    9.923687]  [<c10cca12>] ? call_rcu+0x12/0x20
[    9.923894]  [<c1085b35>] ? creds_are_invalid+0x25/0x60
[    9.924127]  [<c1085bdd>] ? __validate_process_creds+0x6d/0xd0
[    9.924394]  [<c10963be>] ? print_held_locks_bug+0xe/0x80
[    9.924636]  [<c105fb2d>] do_exit+0x20d/0x3e0
[    9.924843]  [<c17ab2e5>] oops_end+0x95/0xd0
[    9.925056]  [<c1015e04>] die+0x54/0x80
[    9.925243]  [<c17aa9f6>] do_trap+0x96/0xd0
[    9.925443]  [<c1013e30>] ? do_coprocessor_segment_overrun+0x90/0x90
[    9.925716]  [<c1013ebc>] do_invalid_op+0x8c/0xb0
[    9.925935]  [<c1140383>] ? kfree+0x1e3/0x280
[    9.926141]  [<c17a9d65>] ? _raw_spin_unlock_irqrestore+0x65/0x80
[    9.926404]  [<c1098579>] ? trace_hardirqs_on_caller+0x19/0xa0
[    9.926661]  [<c17a9d44>] ? _raw_spin_unlock_irqrestore+0x44/0x80
[    9.926925]  [<c134c0ae>] ? debug_object_active_state+0xde/0x120
[    9.927187]  [<c17aa7ab>] ? error_code+0x5b/0x64
[    9.927398]  [<c1013e30>] ? do_coprocessor_segment_overrun+0x90/0x90
[    9.927467]  [<c1094540>] ? trace_hardirqs_off_caller+0x20/0x130
[    9.927467]  [<c133904c>] ? trace_hardirqs_off_thunk+0xc/0x10
[    9.927467]  [<c17aa7af>] error_code+0x5f/0x64
[    9.927467]  [<c11401df>] ? kfree+0x3f/0x280
[    9.927467]  [<c15f5f39>] ? ipv4_frags_exit_net+0x29/0x50
[    9.927467]  [<c1013e30>] ? do_coprocessor_segment_overrun+0x90/0x90
[    9.927467]  [<c1140383>] ? kfree+0x1e3/0x280
[    9.927467]  [<c15f5f39>] ipv4_frags_exit_net+0x29/0x50
[    9.927467]  [<c159eaef>] ops_exit_list+0x2f/0x50
[    9.927467]  [<c159f369>] cleanup_net+0xd9/0x170
[    9.927467]  [<c10778d8>] process_one_work+0x1d8/0x4c0
[    9.927467]  [<c107785c>] ? process_one_work+0x15c/0x4c0
[    9.927467]  [<c159f290>] ? register_pernet_subsys+0x40/0x40
[    9.927467]  [<c1078b70>] worker_thread+0x140/0x3a0
[    9.927467]  [<c17a7462>] ? preempt_schedule+0x32/0x50
[    9.927467]  [<c1078a30>] ? manage_workers+0x110/0x110
[    9.927467]  [<c107dac4>] kthread+0x74/0x80
[    9.927467]  [<c107da50>] ? __init_kthread_worker+0x60/0x60
[    9.927467]  [<c17b0e7a>] kernel_thread_helper+0x6/0x10
[    9.927467] Code: 8d 74 26 00 64 a1 ac 7d b9 c1 8b 80 6c 02 00 00 5d 8b 40
f8 c3 8d b4 26 00 00 00 00 55 89 e5 3e 8d 74 26 00 8b 80 6c 02 00 00 5d <8b> 40
fc c3 8d b6 00 00 00 00 8d bc 27 00 00 00 00 55 89 e5 3e 
[    9.927467] EIP: [<c107d61f>] kthread_data+0xf/0x20 SS:ESP 0068:c78edca0
[    9.927467] CR2: 00000000fffffffc
[    9.927467] ---[ end trace b8a3675a10c16a9d ]---
[    9.927467] Fixing recursive fault but reboot is needed!
No further messages. Kernel freezes.



On 100/1000 of cases, there is line:

[    5.843059] remove_proc_entry: removing non-empty directory 'net/rpc',
leaking at least 'auth.unix.gid'

And on 63/1000 of cases, there is instead:

[    9.972779] remove_proc_entry: removing non-empty directory 'net/rpc',
leaking at least 'nfs'


Full kernel message from serial line in qemu attached and config.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
