From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 15:16:08 +0100
Message-ID: <4B701CA8.7050205@itcare.pl>
References: <4B700EC2.5090207@itcare.pl>	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl>	 <1265637067.3048.14.camel@edumazet-laptop>  <4B7018DF.8060600@itcare.pl> <1265638014.3048.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:44985 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751571Ab0BHOQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 09:16:10 -0500
In-Reply-To: <1265638014.3048.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-02-08 15:06, Eric Dumazet pisze:
> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:59 +0100, Pawe=C5=82 Staszews=
ki a =C3=A9crit :
>   =20
>> W dniu 2010-02-08 14:51, Eric Dumazet pisze:
>>     =20
>>> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:33 +0100, Pawe=C5=82 Stasze=
wski a =C3=A9crit :
>>>
>>>
>>>       =20
>>>>>
>>>>>           =20
>>>> Yes this is x86_64 kernel
>>>> i kernels  2.6.32.2 /  2.6.32.7 and now 2.6.33-rc6-git5 and on all
>>>> kernels the same thing happens.
>>>> grep . /proc/sys/net/ipv4/route/*
>>>> /proc/sys/net/ipv4/route/error_burst:1250
>>>> /proc/sys/net/ipv4/route/error_cost:250
>>>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
>>>> /proc/sys/net/ipv4/route/gc_elasticity:2
>>>> /proc/sys/net/ipv4/route/gc_interval:2
>>>> /proc/sys/net/ipv4/route/gc_min_interval:0
>>>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>>>> /proc/sys/net/ipv4/route/gc_thresh:65535
>>>> /proc/sys/net/ipv4/route/gc_timeout:300
>>>> /proc/sys/net/ipv4/route/max_size:524288
>>>> /proc/sys/net/ipv4/route/min_adv_mss:256
>>>> /proc/sys/net/ipv4/route/min_pmtu:552
>>>> /proc/sys/net/ipv4/route/mtu_expires:600
>>>> /proc/sys/net/ipv4/route/redirect_load:5
>>>> /proc/sys/net/ipv4/route/redirect_number:9
>>>> /proc/sys/net/ipv4/route/redirect_silence:5120
>>>> /proc/sys/net/ipv4/route/secret_interval:2
>>>>
>>>> This happens not all the time.
>>>> I have this info only when there are "internet rush hours" - thn t=
here
>>>> is about 700Mbit/s TX + 700Mbit/s RX forwarded traffic
>>>>
>>>>
>>>>         =20
>>> I dont understand your settings, they are very very small for your
>>> setup. You want to flush cache every 2 seconds...
>>>
>>> With 12GB of ram, you could have
>>>
>>> /proc/sys/net/ipv4/route/gc_thresh:524288
>>> /proc/sys/net/ipv4/route/max_size:8388608
>>> /proc/sys/net/ipv4/route/secret_interval:3600
>>> /proc/sys/net/ipv4/route/gc_elasticity:4
>>> /proc/sys/net/ipv4/route/gc_interval:1
>>>
>>> That would allow about 2 million entries in your route cache, using=
 768
>>> Mbytes of ram, and a good cache hit ratio.
>>>
>>>
>>>
>>>       =20
>> Yes as i write i change this settings after i see first info
>> "secret_interval" - from 3600 to 2
>> To check if this resolve the problem.
>> Also my normal settings are:
>>
>> /proc/sys/net/ipv4/route/gc_thresh:256000
>> /proc/sys/net/ipv4/route/max_size:1048576
>> /proc/sys/net/ipv4/route/secret_interval:3600
>> /proc/sys/net/ipv4/route/gc_interval:2
>> /proc/sys/net/ipv4/route/gc_elasticity:2
>>
>> And with this setting i was have this info:
>> Route hash chain too long!
>> Adjust your secret_interval!
>>
>>
>>
>> Now i put Your settings as You suggest ... and we will see but i don=
t know it will help.
>> Because i try many of different settings.
>>
>>     =20
> One important point is the size of hash table, you want something big
> for your router.
>
> # dmesg | grep 'IP route'
>   ... IP route cache hash table entries: 524288 (order: 10, 4194304
> bytes)
>
>   =20

On my machine it is also the same:
dmesg | grep 'IP route'
IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)


> Then if it is correctly sized, dont change gc_thresh or max_size, as
> defaults are good.
>
> I would only change gc_interval to 1, to perform a smooth gc
>
> And eventually gc_elasticity to 4, 5 or 6 if I had less ram than your
> machine.
>
>   =20
Some day ago after info about route cache i was have  also this info:
=46eb  4 13:12:40 TM_01_C1 ------------[ cut here ]------------
=46eb  4 13:12:40 TM_01_C1 WARNING: at net/sched/sch_generic.c:261=20
dev_watchdog+0x130/0x1d6()
=46eb  4 13:12:40 TM_01_C1 Hardware name: X7DCT
=46eb  4 13:12:40 TM_01_C1 NETDEV WATCHDOG: eth0 (e1000e): transmit que=
ue=20
0 timed out
=46eb  4 13:12:40 TM_01_C1 Modules linked in: oprofile
=46eb  4 13:12:40 TM_01_C1 Pid: 0, comm: swapper Not tainted 2.6.32 #1
=46eb  4 13:12:40 TM_01_C1 Call Trace:
=46eb  4 13:12:40 TM_01_C1 <IRQ>  [<ffffffff812fcaf7>] ?=20
dev_watchdog+0x130/0x1d6
=46eb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0x=
1d6
=46eb  4 13:12:40 TM_01_C1 [<ffffffff81038811>] ?=20
warn_slowpath_common+0x77/0xa3
=46eb  4 13:12:40 TM_01_C1 [<ffffffff81038899>] ? warn_slowpath_fmt+0x5=
1/0x59
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8102897e>] ? activate_task+0x3f/0x=
4e
=46eb  4 13:12:40 TM_01_C1 [<ffffffff81034fe5>] ? try_to_wake_up+0x1eb/=
0x1f8
=46eb  4 13:12:40 TM_01_C1 [<ffffffff812eb768>] ? netdev_drivername+0x3=
b/0x40
=46eb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0x=
1d6
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8102d1e3>] ? __wake_up+0x30/0x44
=46eb  4 13:12:40 TM_01_C1 [<ffffffff812fc9c7>] ? dev_watchdog+0x0/0x1d=
6
=46eb  4 13:12:40 TM_01_C1 [<ffffffff810448c4>] ?=20
run_timer_softirq+0x1ff/0x29d
=46eb  4 13:12:40 TM_01_C1 [<ffffffff810556ab>] ? ktime_get+0x5f/0xb7
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8103e0fd>] ? __do_softirq+0xd7/0x1=
96
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8100be7c>] ? call_softirq+0x1c/0x2=
8
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8100d645>] ? do_softirq+0x31/0x66
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8101b148>] ?=20
smp_apic_timer_interrupt+0x87/0x95
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8100b873>] ?=20
apic_timer_interrupt+0x13/0x20
=46eb  4 13:12:40 TM_01_C1 <EOI>  [<ffffffff810111f5>] ? mwait_idle+0x9=
b/0xa0
=46eb  4 13:12:40 TM_01_C1 [<ffffffff8100a236>] ? cpu_idle+0x49/0x7c
=46eb  4 13:12:40 TM_01_C1 ---[ end trace c670a6a17be040e5 ]---

And after change kernel to 2.6.33-rc6 another different inf:

BUG: soft lockup - CPU#1 stuck for 61s!
[events/1:28]
Modules linked in:
CPU 1
Pid: 28, comm: events/1 Not tainted 2.6.33-rc6-git5 #1 X7DCT/X7DCT
RIP: 0010:[<ffffffff810a3d89>]  [<ffffffff810a3d89>]
kmem_cache_free+0x11b/0x11c
RSP: 0018:ffff880028243e50  EFLAGS: 00000292
RAX: 0000000000000032 RBX: 000000000000007d RCX: ffff8803190683c0
RDX: 0000000000000031 RSI: ffff8803190683c0 RDI: ffff88031f83e680
RBP: ffffffff81002893 R08: 0000000000000000 R09: 000000000000007c
R10: ffff88030d776800 R11: ffff88030d7768a0 R12: ffff880028243dd0
R13: ffffc900008b2f80 R14: ffff88031fa7c800 R15: ffffffff81012da7
=46S:  0000000000000000(0000) GS:ffff880028240000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fd61d5bd000 CR3: 000000031e55c000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process events/1 (pid: 28, threadinfo ffff88031f9c8000, task ffff88031f=
9a4f80)
Stack:
  ffffffff8126826f ffff88031faa4600 ffffffff8126834a 000096ba00000023
<0>  01ffc90000000024 ffff88031fbb4000 ffff88031faa4600 000000000000004=
0
<0>  0000000000000040 ffff88031faa4788 ffff88031faa4600 000000000000074=
0
Call Trace:
  <IRQ>
  [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
  <EOI>
  [<ffffffff81004599>] ? do_softirq+0x31/0x63
  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
  [<ffffffff810479bd>] ? kthread+0x79/0x81
  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
  [<ffffffff81047944>] ? kthread+0x0/0x81
  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
Code: fe 79 4c 00 48 85 db 74 14 48 8b 74 24 10 48 89 ef ff 13 48 83 c3=
 08 48
83 3b 00 eb ea 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f<c3>  55 48 89 =
f5 53 48
89 fb 48 83 ec 08 48 8b 76 18 48 2b 75 10
Call Trace:
  <IRQ>   [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
  <EOI>   [<ffffffff81004599>] ? do_softirq+0x31/0x63
  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
  [<ffffffff810479bd>] ? kthread+0x79/0x81
  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
  [<ffffffff81047944>] ? kthread+0x0/0x81


  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10




>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   =20

