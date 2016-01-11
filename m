From: Grant Zhang <gzhang@fastly.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Mon, 11 Jan 2016 12:27:33 -0800
Message-ID: <56941035.9040000@fastly.com>
References: <5726932.6r4XOZ2Km2@rofl>
 <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
 <56492A39.2060307@fastly.com>
 <1447686469.22599.67.camel@edumazet-glaptop2.roam.corp.google.com>
 <564A129F.5060705@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Schaaf <kernelorg@bof.de>, NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564A129F.5060705@fastly.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/11/2015 09:30, Grant Zhang wrote:
> On 16/11/2015 07:07, Eric Dumazet wrote:
>> On Sun, 2015-11-15 at 16:58 -0800, Grant Zhang wrote:
>>> Hi Patrick,
>>>
>>> Have you tried the two patches Eric mentioned? One of my 4.1.11 server
>>> just hanged with very similar stack trace and I am wondering whether the
>>> aforementioned patches would help.
>>>
>>> Thanks,
>>
>> linux-4.1.12 definitely contains the fixes.
>>
>> 8ae3dfacdd82 inet: fix race in reqsk_queue_unlink()
>> 31b8abd140ad inet: fix races in reqsk_queue_hash_req()
>>
>> Please upgrade to 4.1.13 and you should be fine.
>>
>> Thanks.
>>
>>
>
> Thank you Eric and Patrick. I will upgrade to 4.1.13.
>
> Grant

Hi Eric,

One of my 4.1.13 server(have been up 50+ days) under testing got into a 
similar kernel hang (stack trace attached). Looking back at the initial 
conversation on this issue you also mentioned the following patch in
https://lkml.org/lkml/2015/9/23/433

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
tcp/dccp: fix timewait races in timer handling

Which does not seem to be part of stable 4.1 tree. Would the above patch 
fix the kernel hang issue?

Thanks,

Grant

----stacktrace----
Jan  9 19:12:42 kernel:[4544972.126385] INFO: rcu_sched self-detected 
stall on CPU { 13}  (t=15001 jiffies g=422586407 c=422586406 q=3730083)
Jan  9 19:12:42 kernel:[4544972.134383] INFO: rcu_sched detected stalls 
on CPUs/tasks: { 13} (detected by 5, t=15002 jiffies, g=422586407, 
c=422586406, q=3730200)
Jan  9 19:12:42 kernel:[4544972.134384] Task dump for CPU 13:
Jan  9 19:12:42 kernel:[4544972.134387] swapper/13      R  running task 
        0     0      1 0x00000008
Jan  9 19:12:42 kernel:[4544972.134389]  0000000000000010 
0000000000000246 ffff885ecde0be68 0000000000000018
Jan  9 19:12:42 kernel:[4544972.134390]  ffffffff8164045d 
ffffffff00000007 00102982b9fa1875 ffffffff81c7fc80
Jan  9 19:12:42 kernel:[4544972.134391]  0000000d00000000 
ffff88beff0e0300 ffffffff81ce5448 ffff885ecde08000
Jan  9 19:12:42 kernel:[4544972.134391] Call Trace:
Jan  9 19:12:42 kernel:[4544972.134397]  [<ffffffff8164045d>] ? 
cpuidle_enter_state+0x7d/0x1f0
Jan  9 19:12:42 kernel:[4544972.134398]  [<ffffffff81640607>] ? 
cpuidle_enter+0x17/0x20
Jan  9 19:12:42 kernel:[4544972.134401]  [<ffffffff810b6c41>] ? 
cpu_startup_entry+0x2d1/0x350
Jan  9 19:12:42 kernel:[4544972.134403]  [<ffffffff810e0aac>] ? 
clockevents_config_and_register+0x2c/0x40
Jan  9 19:12:42 kernel:[4544972.134406]  [<ffffffff81034aa3>] ? 
start_secondary+0x123/0x130
Jan  9 19:12:42 kernel:[4544972.149242] Task dump for CPU 13:
Jan  9 19:12:42 kernel:[4544972.149244] swapper/13      R  running task 
        0     0      1 0x00000008
Jan  9 19:12:42 kernel:[4544972.149248]  ffffffff81c3f300 
ffff88beff0c3820 ffffffff810a5791 000000000000000d
Jan  9 19:12:42 kernel:[4544972.149250]  ffffffff81c3f300 
ffff88beff0c3840 ffffffff810a8c4f ffff88beff0c3880
Jan  9 19:12:42 kernel:[4544972.149251]  ffffffff81c3f3c0 
ffff88beff0c3870 ffffffff810ca763 ffff88beff0d6c80
Jan  9 19:12:42 kernel:[4544972.149253] Call Trace:
Jan  9 19:12:42 kernel:[4544972.149255]  <IRQ>  [<ffffffff810a5791>] 
sched_show_task+0xb1/0x120
Jan  9 19:12:42 kernel:[4544972.149267]  [<ffffffff810a8c4f>] 
dump_cpu_task+0x3f/0x50
Jan  9 19:12:42 kernel:[4544972.149270]  [<ffffffff810ca763>] 
rcu_dump_cpu_stacks+0x93/0xc0
Jan  9 19:12:42 kernel:[4544972.149272]  [<ffffffff810cdcaa>] 
rcu_check_callbacks+0x4aa/0x760
Jan  9 19:12:42 kernel:[4544972.149277]  [<ffffffff8110e27c>] ? 
acct_account_cputime+0x1c/0x20
Jan  9 19:12:42 kernel:[4544972.149279]  [<ffffffff810d3868>] 
update_process_times+0x38/0x70
Jan  9 19:12:42 kernel:[4544972.149283]  [<ffffffff810e2a38>] 
tick_sched_timer+0x58/0x190
Jan  9 19:12:42 kernel:[4544972.149284]  [<ffffffff810d41ad>] 
__run_hrtimer+0x6d/0x220
Jan  9 19:12:42 kernel:[4544972.149285]  [<ffffffff810e29e0>] ? 
tick_init_highres+0x20/0x20
Jan  9 19:12:42 kernel:[4544972.149287]  [<ffffffff810d4893>] 
hrtimer_interrupt+0x103/0x240
Jan  9 19:12:42 kernel:[4544972.149292]  [<ffffffff810363f9>] 
local_apic_timer_interrupt+0x39/0x60
Jan  9 19:12:42 kernel:[4544972.149296]  [<ffffffff817b5275>] 
smp_apic_timer_interrupt+0x45/0x60
Jan  9 19:12:42 kernel:[4544972.149299]  [<ffffffff817b39bb>] 
apic_timer_interrupt+0x6b/0x70
Jan  9 19:12:42 kernel:[4544972.149304]  [<ffffffff816f36f0>] ? 
__inet_lookup_established+0x70/0x170
Jan  9 19:12:42 kernel:[4544972.149306]  [<ffffffff816f36c6>] ? 
__inet_lookup_established+0x46/0x170
Jan  9 19:12:42 kernel:[4544972.149309]  [<ffffffff8170eb7d>] 
tcp_v4_early_demux+0xad/0x160
Jan  9 19:12:42 kernel:[4544972.149311]  [<ffffffff816e9428>] 
ip_rcv_finish+0x158/0x380
Jan  9 19:12:42 kernel:[4544972.149312]  [<ffffffff816e9cf2>] 
ip_rcv+0x292/0x3b0
Jan  9 19:12:42 kernel:[4544972.149318]  [<ffffffffa04f0102>] ? 
macvlan_handle_frame+0x1f2/0x310 [macvlan]
Jan  9 19:12:42 kernel:[4544972.149320]  [<ffffffff816e92d0>] ? 
inet_add_protocol+0x50/0x50
Jan  9 19:12:42 kernel:[4544972.149324]  [<ffffffff81693bf0>] 
__netif_receive_skb_core+0x300/0x7b0
Jan  9 19:12:42 kernel:[4544972.149325]  [<ffffffff817b5185>] ? 
do_IRQ+0x65/0x110
Jan  9 19:12:42 kernel:[4544972.149327]  [<ffffffff816940c1>] 
__netif_receive_skb+0x21/0x70
Jan  9 19:12:42 kernel:[4544972.149329]  [<ffffffff81694271>] 
netif_receive_skb_internal+0x31/0xa0
Jan  9 19:12:42 kernel:[4544972.149331]  [<ffffffff81694ff0>] 
napi_gro_receive+0x130/0x1b0
Jan  9 19:12:42 kernel:[4544972.149341]  [<ffffffffa005f389>] 
ixgbe_clean_rx_irq+0x7b9/0xa20 [ixgbe]
Jan  9 19:12:42 kernel:[4544972.149344]  [<ffffffffa006024b>] 
ixgbe_poll+0x42b/0x7e0 [ixgbe]
Jan  9 19:12:42 kernel:[4544972.149346]  [<ffffffff816949ce>] 
net_rx_action+0x13e/0x320
Jan  9 19:12:42 kernel:[4544972.149350]  [<ffffffff8107fcce>] 
__do_softirq+0xde/0x2d0
Jan  9 19:12:42 kernel:[4544972.149352]  [<ffffffff8108009d>] 
irq_exit+0x4d/0x60
Jan  9 19:12:42 kernel:[4544972.149353]  [<ffffffff817b5185>] 
do_IRQ+0x65/0x110
Jan  9 19:12:42 kernel:[4544972.149356]  [<ffffffff817b36eb>] 
common_interrupt+0x6b/0x6b
Jan  9 19:12:42 kernel:[4544972.149356]  <EOI>  [<ffffffff8164048e>] ? 
cpuidle_enter_state+0xae/0x1f0
Jan  9 19:12:42 kernel:[4544972.149360]  [<ffffffff8164045d>] ? 
cpuidle_enter_state+0x7d/0x1f0
Jan  9 19:12:42 kernel:[4544972.149361]  [<ffffffff81640607>] 
cpuidle_enter+0x17/0x20
Jan  9 19:12:42 kernel:[4544972.149364]  [<ffffffff810b6c41>] 
cpu_startup_entry+0x2d1/0x350
Jan  9 19:12:42 kernel:[4544972.149366]  [<ffffffff810e0aac>] ? 
clockevents_config_and_register+0x2c/0x40
Jan  9 19:12:42 kernel:[4544972.149368]  [<ffffffff81034aa3>] 
start_secondary+0x123/0x130
