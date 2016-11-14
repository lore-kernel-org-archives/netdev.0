From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [net]  2ab9fb18c4: kernel BUG at include/linux/skbuff.h:1935!
Date: Mon, 14 Nov 2016 10:14:20 +0800
Message-ID: <20161114021420.GC31218@yexl-desktop>
References: <5828fc09.rTUEnj6qw0eDHzYL%xiaolong.ye@intel.com>
 <1479088020.8455.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkp@01.org, netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Jojy Varghese <jojvargh@cisco.com>,
        Tom Herbert <tom@herbertland.com>,
        Yibin Yang <yibyang@cisco.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56448 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753682AbcKNCPU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 21:15:20 -0500
Content-Disposition: inline
In-Reply-To: <1479088020.8455.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13, Eric Dumazet wrote:
>On Mon, 2016-11-14 at 07:49 +0800, kernel test robot wrote:
>> FYI, we noticed the following commit:
>
>
>> in testcase: kbuild
>> with following parameters:
>> 
>> 	runtime: 300s
>> 	nr_task: 50%
>> 	cpufreq_governor: performance
>> 
>> 
>> 
>> 
>> on test machine: 8 threads Intel(R) Atom(TM) CPU  C2750  @ 2.40GHz with 16G memory
>> 
>> caused below changes:
>> 
>> 
>> +-------------------------------------------------------+------------+------------+
>> |                                                       | cdb26d3387 | 2ab9fb18c4 |
>> +-------------------------------------------------------+------------+------------+
>> | boot_successes                                        | 10         | 3          |
>> | boot_failures                                         | 0          | 9          |
>> | kernel_BUG_at_include/linux/skbuff.h                  | 0          | 8          |
>> | invalid_opcode:#[##]SMP                               | 0          | 8          |
>> | RIP:eth_type_trans                                    | 0          | 8          |
>> | Kernel_panic-not_syncing:Fatal_exception_in_interrupt | 0          | 5          |
>> | WARNING:at_fs/sysfs/dir.c:#sysfs_warn_dup             | 0          | 1          |
>> | calltrace:parport_pc_init                             | 0          | 1          |
>> | calltrace:SyS_finit_module                            | 0          | 1          |
>> | WARNING:at_lib/kobject.c:#kobject_add_internal        | 0          | 1          |
>> +-------------------------------------------------------+------------+------------+
>> 
>> 
>> 
>> [   20.491020] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [   20.502988] Sending DHCP requests .
>> [   20.506729] ------------[ cut here ]------------
>> [   20.511369] kernel BUG at include/linux/skbuff.h:1935!
>> [   20.517893] invalid opcode: 0000 [#1] SMP
>> [   20.521902] Modules linked in:
>> [   20.524979] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 4.9.0-rc3-00286-g2ab9fb1 #1
>> [   20.532463] Hardware name: Supermicro SYS-5018A-TN4/A1SAi, BIOS 1.1a 08/27/2015
>> [   20.539768] task: ffff8804456c2480 task.stack: ffffc90001920000
>> [   20.545684] RIP: 0010:[<ffffffff81837b48>]  [<ffffffff81837b48>] eth_type_trans+0xe8/0x140
>> [   20.553972] RSP: 0018:ffff88047fd03db8  EFLAGS: 00010297
>> [   20.559283] RAX: 0000000000000158 RBX: ffff88047d8ae600 RCX: 0000000000001073
>> [   20.566415] RDX: ffff88047bf07dc0 RSI: ffff88047d8a4000 RDI: ffff88047dac0f00
>> [   20.573546] RBP: ffff88047fd03e20 R08: ffff88047d8a4000 R09: 0000000000000800
>> [   20.580678] R10: ffff88047bf07ec0 R11: ffffea0011f6e400 R12: ffff88047dac0f00
>> [   20.587810] R13: ffff880457413000 R14: ffffc90002129000 R15: 000000000000015e
>> [   20.594946] FS:  0000000000000000(0000) GS:ffff88047fd00000(0000) knlGS:0000000000000000
>> [   20.603032] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   20.608775] CR2: 00007fffadfb4ef0 CR3: 000000047ee07000 CR4: 00000000001006e0
>> [   20.615906] Stack:
>> [   20.617927]  ffffffff816905a7 ffffea0011f6e400 ffffea0000000008 ffff88047d8ae450
>> [   20.625403]  ffff88047d8ae400 0000004000000166 ffffea0011f6e400 0000ffff00000000
>> [   20.632873]  0000000000000040 0000000000000000 ffff88047d8ae450 ffff88047d8b1140
>> [   20.640352] Call Trace:
>> [   20.642805]  <IRQ> 
>> [   20.644740]  [<ffffffff816905a7>] ? igb_clean_rx_irq+0x6a7/0x7d0
>> [   20.650760]  [<ffffffff81690a52>] igb_poll+0x382/0x700
>> [   20.655904]  [<ffffffff8146edd9>] ? timerqueue_add+0x59/0xb0
>> [   20.661564]  [<ffffffff8180f2d7>] net_rx_action+0x217/0x360
>> [   20.667137]  [<ffffffff81957ef4>] __do_softirq+0x104/0x2ab
>> [   20.672624]  [<ffffffff81086961>] irq_exit+0xf1/0x100
>> [   20.677673]  [<ffffffff81957c34>] do_IRQ+0x54/0xd0
>> [   20.682466]  [<ffffffff81955acc>] common_interrupt+0x8c/0x8c
>> [   20.688123]  <EOI> 
>> [   20.690054]  [<ffffffff817c1d12>] ? cpuidle_enter_state+0x122/0x2e0
>> [   20.696333]  [<ffffffff817c1f07>] cpuidle_enter+0x17/0x20
>> [   20.701733]  [<ffffffff810c64c3>] call_cpuidle+0x23/0x40
>> [   20.707045]  [<ffffffff810c66f4>] cpu_startup_entry+0x114/0x200
>> [   20.712964]  [<ffffffff81051c87>] start_secondary+0x107/0x130
>> [   20.718708] Code: 00 04 00 00 c9 c3 48 33 86 70 03 00 00 48 c1 e0 10 48 85 c0 0f b6 87 90 00 00 00 75 28 83 e0 f8 83 c8 01 88 87 90 00 00 00 eb 82 <0f> 0b 0f b6 87 90 00 00 00 83 e0 f8 83 c8 03 88 87 90 00 00 00 
>> [   20.738722] RIP  [<ffffffff81837b48>] eth_type_trans+0xe8/0x140
>> [   20.744662]  RSP <ffff88047fd03db8>
>> [   20.748160] ---[ end trace 153440bf1ca2e6fc ]---
>> [   20.748165] ------------[ cut here ]------------
>> 
>> 
>> To reproduce:
>> 
>>         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
>>         cd lkp-tests
>>         bin/lkp install job.yaml  # job file is attached in this email
>>         bin/lkp run     job.yaml
>> 
>> 
>> 
>> Thanks,
>> Kernel Test Robot
>
>
>Hi guys.
>
>I took a look at the commit again and I do not see how this can happen.
>
>Are you sure patch was properly applied ?
>
>In particular, the following extract is obscure for me :
>
>
>> https://github.com/0day-ci/linux Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839
>> commit 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb ("net: __skb_flow_dissect() must cap its return value")
>> 

Hi,

The above two lines means 0day repo setup a new branch
"Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839"
which is based on net/master, then applied you patch on top of it,
commit id is 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb.

Thanks,
Xiaolong

>
>Thanks.
>
>
