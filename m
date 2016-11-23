From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [LKP] [net] 34fad54c25: kernel BUG at
 include/linux/skbuff.h:1935!
Date: Wed, 23 Nov 2016 14:44:21 +0800
Message-ID: <20161123064421.cewko2msg7mdawco@wfg-t540p.sh.intel.com>
References: <582b7c30.nXQXP2V4/6pFiYwt%xiaolong.ye@intel.com>
 <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: kernel test robot <xiaolong.ye@intel.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, LKP <lkp@01.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

On Tue, Nov 22, 2016 at 02:04:42PM -0800, Linus Torvalds wrote:
[snip]

>I also noticed that the kernel test robot had screwed up the
>participants list for some reason, and had
>
>  "Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>, David S.
>Miller" <davem@davemloft.net>
>
>as one of the participants. So there's some odd commit parsing issue
>there somewhere. But Alexander seems to have seen this report despite
>that, it just never went anywhere that I can tell.

Yeah the robot will CC all "Acked-by" people in the bug reports.

Shall we limit it to the below TO/CC list?

        TO: author
        CC: committer (maintainer)
        CC: all Signed-off-by
        CC: all Reviewed-by
        CC: mailing lists, if the bug is found in a maintainer/well known tree

Regards,
Fengguang

>On Tue, Nov 15, 2016 at 1:20 PM, kernel test robot
><xiaolong.ye@intel.com> wrote:
>>
>> FYI, we noticed the following commit:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> commit 34fad54c2537f7c99d07375e50cb30aa3c23bd83 ("net: __skb_flow_dissect() must cap its return value")
>>
>> in testcase: pbzip2
>> with following parameters:
>>
>>         nr_threads: 25%
>>         blocksize: 900K
>>         cpufreq_governor: performance
>>
>>
>>
>> on test machine: 48 threads 2 sockets Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz with 64G memory
>>
>> caused below changes:
>>
>>
>> +------------------------------------------------------------------+------------+------------+
>> |                                                                  | 79774d6bfa | 34fad54c25 |
>> +------------------------------------------------------------------+------------+------------+
>> | boot_successes                                                   | 0          | 2          |
>> | boot_failures                                                    | 2          | 20         |
>> | invoked_oom-killer:gfp_mask=0x                                   | 2          | 2          |
>> | Mem-Info                                                         | 2          | 2          |
>> | Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 2          | 2          |
>> | kernel_BUG_at_include/linux/skbuff.h                             | 0          | 16         |
>> | invalid_opcode:#[##]SMP                                          | 0          | 16         |
>> | RIP:eth_type_trans                                               | 0          | 16         |
>> | Kernel_panic-not_syncing:Fatal_exception_in_interrupt            | 0          | 15         |
>> | calltrace:hub_event                                              | 0          | 1          |
>> | WARNING:at_fs/sysfs/dir.c:#sysfs_warn_dup                        | 0          | 2          |
>> | calltrace:parport_pc_init                                        | 0          | 2          |
>> | calltrace:SyS_finit_module                                       | 0          | 2          |
>> | WARNING:at_lib/kobject.c:#kobject_add_internal                   | 0          | 2          |
>> +------------------------------------------------------------------+------------+------------+
>>
>>
>>
>> [   19.375251] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
>> [   19.388892] Sending DHCP requests .
>> [   19.388892] ------------[ cut here ]------------
>> [   19.388894] kernel BUG at include/linux/skbuff.h:1935!
>> [   19.388895] invalid opcode: 0000 [#1] SMP
>> [   19.388896] Modules linked in:
>> [   19.388897] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.0-rc3-00320-g34fad54 #1
>> [   19.388898] Hardware name: Intel Corporation S2600WP/S2600WP, BIOS SE5C600.86B.02.02.0002.122320131210 12/23/2013
>> [   19.388899] task: ffffffff81e0e4c0 task.stack: ffffffff81e00000
>> [   19.388904] RIP: 0010:[<ffffffff81837c48>]  [<ffffffff81837c48>] eth_type_trans+0xe8/0x140
>> [   19.388904] RSP: 0000:ffff88081e803db8  EFLAGS: 00010297
>> [   19.388905] RAX: 0000000000000152 RBX: ffff88080221f200 RCX: 0000000000001073
>> [   19.388905] RDX: ffff8808013afdc0 RSI: ffff880801114000 RDI: ffff880819407c00
>> [   19.388906] RBP: ffff88081e803e20 R08: ffff880801114000 R09: 0000000000000800
>> [   19.388907] R10: ffff8808013afec0 R11: ffffea003fd5a880 R12: ffff880819407c00
>> [   19.388907] R13: ffff881033408000 R14: ffffc9000843e000 R15: 0000000000000158
>> [   19.388908] FS:  0000000000000000(0000) GS:ffff88081e800000(0000) knlGS:0000000000000000
>> [   19.388909] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   19.388910] CR2: ffff88103ffff000 CR3: 0000000001e07000 CR4: 00000000001406f0
>> [   19.388910] Stack:
>> [   19.388912]  ffffffff816905a7 ffffea003fd5a880 ffffea0000000008 ffff88080221f050
>> [   19.388913]  ffff88080221f000 0000004000000160 ffffea003fd5a880 0000000000000000
>> [   19.388915]  0000000000000040 0000000000000000 ffff88080221f050 ffff88100d216000
>> [   19.388915] Call Trace:
>> [   19.388919]  <IRQ>
>> [   19.388919]  [<ffffffff816905a7>] ? igb_clean_rx_irq+0x6a7/0x7d0
>> [   19.388921]  [<ffffffff81690a52>] igb_poll+0x382/0x700
>> [   19.388922]  [<ffffffff81690a67>] ? igb_poll+0x397/0x700
>> [   19.388925]  [<ffffffff8180f2d7>] net_rx_action+0x217/0x360
>> [   19.388928]  [<ffffffff81957fb4>] __do_softirq+0x104/0x2ab
>> [   19.388931]  [<ffffffff81086961>] irq_exit+0xf1/0x100
>> [   19.388932]  [<ffffffff81957cf4>] do_IRQ+0x54/0xd0
>> [   19.388935]  [<ffffffff81955b8c>] common_interrupt+0x8c/0x8c
>> [   19.388938]  <EOI>
>> [   19.388938]  [<ffffffff817c1d12>] ? cpuidle_enter_state+0x122/0x2e0
>> [   19.388939]  [<ffffffff817c1f07>] cpuidle_enter+0x17/0x20
>> [   19.388942]  [<ffffffff810c64c3>] call_cpuidle+0x23/0x40
>> [   19.388944]  [<ffffffff810c66f4>] cpu_startup_entry+0x114/0x200
>> [   19.388946]  [<ffffffff81947675>] rest_init+0x85/0x90
>> [   19.388950]  [<ffffffff81ffbf5c>] start_kernel+0x407/0x414
>> [   19.388952]  [<ffffffff81ffb120>] ? early_idt_handler_array+0x120/0x120
>> [   19.388953]  [<ffffffff81ffb2d6>] x86_64_start_reservations+0x2a/0x2c
>> [   19.388955]  [<ffffffff81ffb415>] x86_64_start_kernel+0x13d/0x14c
>> [   19.388968] Code: 00 04 00 00 c9 c3 48 33 86 70 03 00 00 48 c1 e0 10 48 85 c0 0f b6 87 90 00 00 00 75 28 83 e0 f8 83 c8 01 88 87 90 00 00 00 eb 82 <0f> 0b 0f b6 87 90 00 00 00 83 e0 f8 83 c8 03 88 87 90 00 00 00
>> [   19.388970] RIP  [<ffffffff81837c48>] eth_type_trans+0xe8/0x140
>> [   19.388970]  RSP <ffff88081e803db8>
>> [   19.388996] ---[ end trace 107996155a43a15c ]---
>> [   19.393422] Kernel panic - not syncing: Fatal exception in interrupt
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
>_______________________________________________
>LKP mailing list
>LKP@lists.01.org
>https://lists.01.org/mailman/listinfo/lkp
