From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 20:57:29 +0100
Message-ID: <4B9556A9.60206@free.fr>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr>	<m1fx4bxlfy.fsf@fess.ebiederm.org> <4B952BBE.6070507@free.fr> <m11vfuvi1t.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m11vfuvi1t.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>
>   
>> Eric W. Biederman wrote:
>>     
>>> I have take an snapshot of my development tree and placed it at.
>>>
>>>
>>> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>>>   
>>>       
>> Hi Eric,
>>
>> thanks for the pointer.
>>
>> I tried to boot the kernel under qemu and I got this oops:
>>     
>
> I am clearly running an old userspace on my test machine.  No udev.
> It looks like udev has a long standing netlink misfeature, where
> it does not initializing NETLINK_CB....
>
>
> >From 8d85e3ab88718eda3d94cf8e1be14b69dae2b8f1 Mon Sep 17 00:00:00 2001
> From: Eric W. Biederman <ebiederm@xmission.com>
> Date: Mon, 8 Mar 2010 09:25:20 -0800
> Subject: [PATCH] kobject_uevent:  Use the netlink allocator helper...
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>   
Thanks.

I was able to boot but I have the following warning:

------------[ cut here ]------------
WARNING: at net/netlink/af_netlink.c:198 netlink_sock_destruct+0x72/0xac()
Hardware name:
Modules linked in: [last unloaded: scsi_wait_scan]
Pid: 840, comm: nash-hotplug Tainted: G        W  2.6.33 #2
Call Trace:
 [<ffffffff812df182>] ? netlink_sock_destruct+0x72/0xac
 [<ffffffff8102ca29>] warn_slowpath_common+0x77/0xa4
 [<ffffffff8102ca65>] warn_slowpath_null+0xf/0x11
 [<ffffffff812df182>] netlink_sock_destruct+0x72/0xac
 [<ffffffff812bb2a4>] __sk_free+0x1e/0x118
 [<ffffffff812bb40d>] sk_free+0x19/0x1b
 [<ffffffff812e0dc2>] netlink_release+0x246/0x253
 [<ffffffff812b825a>] sock_release+0x1a/0x6b
 [<ffffffff812b82cd>] sock_close+0x22/0x26
 [<ffffffff810c7823>] __fput+0x11b/0x1d7
 [<ffffffff810c78f6>] fput+0x17/0x19
 [<ffffffff810c4ae2>] filp_close+0x67/0x72
 [<ffffffff8102e75c>] put_files_struct+0x6a/0xd4
 [<ffffffff8102e80d>] exit_files+0x47/0x4f
 [<ffffffff8102fe59>] do_exit+0x1eb/0x693
 [<ffffffff813864c2>] ? _raw_spin_unlock_irq+0x2b/0x31
 [<ffffffff81030373>] do_group_exit+0x72/0x9b
 [<ffffffff8103f37c>] get_signal_to_deliver+0x3a1/0x3c1
 [<ffffffff81001e8e>] do_notify_resume+0x8d/0x6ea
 [<ffffffff810538c9>] ? trace_hardirqs_on_caller+0x110/0x13a
 [<ffffffff8102851e>] ? finish_task_switch+0x6a/0xb3
 [<ffffffff810284b4>] ? finish_task_switch+0x0/0xb3
 [<ffffffff813867aa>] ? retint_signal+0x11/0x87
 [<ffffffff810538c9>] ? trace_hardirqs_on_caller+0x110/0x13a
 [<ffffffff813867df>] retint_signal+0x46/0x87
---[ end trace d4a1e4cbaa70d63d ]---


And I have a kernel panic when exiting a network namespace using a macvlan:

linux-swk0 login: BUG: unable to handle kernel paging request at 
ffff880035475678
IP: [<ffffffff8128dbef>] macvlan_stop+0x54/0x7a
PGD 160b063 PUD 160f063 PMD 2aa067 PTE 35475160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/net/eth0/flags
CPU 0
Pid: 10, comm: netns Tainted: G        W  2.6.33 #2 /
RIP: 0010:[<ffffffff8128dbef>]  [<ffffffff8128dbef>] macvlan_stop+0x54/0x7a
RSP: 0018:ffff88003f92bc50  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880035440800 RCX: ffff880035440800
RDX: ffff880035475678 RSI: ffff88003f913710 RDI: ffff88003cde9800
RBP: ffff88003f92bc70 R08: 0000000000000004 R09: 0000000000000000
R10: 0080000000000000 R11: ffff88003f92bbf0 R12: ffff88003cde9800
R13: ffff880035440de0 R14: 0080000000000000 R15: 0000000800000000
FS:  0000000000000000(0000) GS:ffffffff8161b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff880035475678 CR3: 000000003eb41000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process netns (pid: 10, threadinfo ffff88003f92a000, task ffff88003f913058)
Stack:
 ffffffff814328a0 ffff880035440800 ffffffff814328a0 ffff88003553a800
<0> ffff88003f92bc90 ffffffff812c9150 ffff880035440800 ffff88003f92bd00
<0> ffff88003f92bcd0 ffffffff812c9259 ffff88003f92bcd0 ffff88003f92bd00
Call Trace:
 [<ffffffff812c9150>] dev_close+0x86/0xa8
 [<ffffffff812c9259>] rollback_registered_many+0xe7/0x208
 [<ffffffff812c9390>] unregister_netdevice_many+0x16/0x62
 [<ffffffff812c952d>] default_device_exit_batch+0x9f/0xb3
 [<ffffffff812c3906>] ops_exit_list+0x4e/0x56
 [<ffffffff812c40f4>] cleanup_net+0xfe/0x1b7
 [<ffffffff81042db6>] worker_thread+0x227/0x32d
 [<ffffffff81042d60>] ? worker_thread+0x1d1/0x32d
 [<ffffffff813864c2>] ? _raw_spin_unlock_irq+0x2b/0x31
 [<ffffffff812c3ff6>] ? cleanup_net+0x0/0x1b7
 [<ffffffff810466ae>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff81042b8f>] ? worker_thread+0x0/0x32d
 [<ffffffff810462e0>] kthread+0x7c/0x84
 [<ffffffff810035b4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8138673a>] ? restore_args+0x0/0x30
 [<ffffffff81046264>] ? kthread+0x0/0x84
 [<ffffffff810035b0>] ? kernel_thread_helper+0x0/0x10
Code: 01 00 00 02 74 0b 83 ce ff 4c 89 e7 e8 a1 8f 03 00 48 8b b3 50 02 
00 00 4c 89 e7 e8 df 8e 03 00 49 8b 45 18 49 8b 55 20 48 85 c0 <48> 89 
02 74 04 48 89 50 08 48 be 00 02 20 00 00 00 ad de 49 89
RIP  [<ffffffff8128dbef>] macvlan_stop+0x54/0x7a
 RSP <ffff88003f92bc50>
CR2: ffff880035475678
---[ end trace d4a1e4cbaa70d63e ]---

addr2line -e ./vmlinux ffffffff812c9150 gives net/core/dev.c:1252
