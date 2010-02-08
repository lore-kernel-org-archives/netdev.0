From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 15:45:11 +0100
Message-ID: <4B702377.5020705@itcare.pl>
References: <4B700EC2.5090207@itcare.pl>	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl>	 <1265637067.3048.14.camel@edumazet-laptop>  <4B7018DF.8060600@itcare.pl> <1265638014.3048.20.camel@edumazet-laptop> <4B701CA8.7050205@itcare.pl> <4B702096.7030101@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:51733 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751622Ab0BHOpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 09:45:12 -0500
In-Reply-To: <4B702096.7030101@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-02-08 15:32, Pawe=C5=82 Staszewski pisze:
> W dniu 2010-02-08 15:16, Pawe=C5=82 Staszewski pisze:
>> W dniu 2010-02-08 15:06, Eric Dumazet pisze:
>>> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:59 +0100, Pawe=C5=82 Stasze=
wski a =C3=A9crit :
>>>> W dniu 2010-02-08 14:51, Eric Dumazet pisze:
>>>>> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:33 +0100, Pawe=C5=82 Stas=
zewski a =C3=A9crit :
>>>>>
>>>>>
>>>>>>>
>>>>>> Yes this is x86_64 kernel
>>>>>> i kernels  2.6.32.2 /  2.6.32.7 and now 2.6.33-rc6-git5 and on a=
ll
>>>>>> kernels the same thing happens.
>>>>>> grep . /proc/sys/net/ipv4/route/*
>>>>>> /proc/sys/net/ipv4/route/error_burst:1250
>>>>>> /proc/sys/net/ipv4/route/error_cost:250
>>>>>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
>>>>>> /proc/sys/net/ipv4/route/gc_elasticity:2
>>>>>> /proc/sys/net/ipv4/route/gc_interval:2
>>>>>> /proc/sys/net/ipv4/route/gc_min_interval:0
>>>>>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>>>>>> /proc/sys/net/ipv4/route/gc_thresh:65535
>>>>>> /proc/sys/net/ipv4/route/gc_timeout:300
>>>>>> /proc/sys/net/ipv4/route/max_size:524288
>>>>>> /proc/sys/net/ipv4/route/min_adv_mss:256
>>>>>> /proc/sys/net/ipv4/route/min_pmtu:552
>>>>>> /proc/sys/net/ipv4/route/mtu_expires:600
>>>>>> /proc/sys/net/ipv4/route/redirect_load:5
>>>>>> /proc/sys/net/ipv4/route/redirect_number:9
>>>>>> /proc/sys/net/ipv4/route/redirect_silence:5120
>>>>>> /proc/sys/net/ipv4/route/secret_interval:2
>>>>>>
>>>>>> This happens not all the time.
>>>>>> I have this info only when there are "internet rush hours" - thn=
=20
>>>>>> there
>>>>>> is about 700Mbit/s TX + 700Mbit/s RX forwarded traffic
>>>>>>
>>>>>>
>>>>> I dont understand your settings, they are very very small for you=
r
>>>>> setup. You want to flush cache every 2 seconds...
>>>>>
>>>>> With 12GB of ram, you could have
>>>>>
>>>>> /proc/sys/net/ipv4/route/gc_thresh:524288
>>>>> /proc/sys/net/ipv4/route/max_size:8388608
>>>>> /proc/sys/net/ipv4/route/secret_interval:3600
>>>>> /proc/sys/net/ipv4/route/gc_elasticity:4
>>>>> /proc/sys/net/ipv4/route/gc_interval:1
>>>>>
>>>>> That would allow about 2 million entries in your route cache,=20
>>>>> using 768
>>>>> Mbytes of ram, and a good cache hit ratio.
>>>>>
>>>>>
>>>>>
>>>> Yes as i write i change this settings after i see first info
>>>> "secret_interval" - from 3600 to 2
>>>> To check if this resolve the problem.
>>>> Also my normal settings are:
>>>>
>>>> /proc/sys/net/ipv4/route/gc_thresh:256000
>>>> /proc/sys/net/ipv4/route/max_size:1048576
>>>> /proc/sys/net/ipv4/route/secret_interval:3600
>>>> /proc/sys/net/ipv4/route/gc_interval:2
>>>> /proc/sys/net/ipv4/route/gc_elasticity:2
>>>>
>>>> And with this setting i was have this info:
>>>> Route hash chain too long!
>>>> Adjust your secret_interval!
>>>>
>>>>
>>>>
>>>> Now i put Your settings as You suggest ... and we will see but i=20
>>>> dont know it will help.
>>>> Because i try many of different settings.
>>>>
>>> One important point is the size of hash table, you want something b=
ig
>>> for your router.
>>>
>>> # dmesg | grep 'IP route'
>>>   ... IP route cache hash table entries: 524288 (order: 10, 4194304
>>> bytes)
>>>
>>
>> On my machine it is also the same:
>> dmesg | grep 'IP route'
>> IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
>>
>>
>>> Then if it is correctly sized, dont change gc_thresh or max_size, a=
s
>>> defaults are good.
>>>
>>> I would only change gc_interval to 1, to perform a smooth gc
>>>
>>> And eventually gc_elasticity to 4, 5 or 6 if I had less ram than yo=
ur
>>> machine.
>>>
>> Some day ago after info about route cache i was have  also this info=
:
>> Feb  4 13:12:40 TM_01_C1 ------------[ cut here ]------------
>> Feb  4 13:12:40 TM_01_C1 WARNING: at net/sched/sch_generic.c:261=20
>> dev_watchdog+0x130/0x1d6()
>> Feb  4 13:12:40 TM_01_C1 Hardware name: X7DCT
>> Feb  4 13:12:40 TM_01_C1 NETDEV WATCHDOG: eth0 (e1000e): transmit=20
>> queue 0 timed out
>> Feb  4 13:12:40 TM_01_C1 Modules linked in: oprofile
>> Feb  4 13:12:40 TM_01_C1 Pid: 0, comm: swapper Not tainted 2.6.32 #1
>> Feb  4 13:12:40 TM_01_C1 Call Trace:
>> Feb  4 13:12:40 TM_01_C1 <IRQ>  [<ffffffff812fcaf7>] ?=20
>> dev_watchdog+0x130/0x1d6
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0=
x1d6
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff81038811>] ?=20
>> warn_slowpath_common+0x77/0xa3
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff81038899>] ?=20
>> warn_slowpath_fmt+0x51/0x59
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8102897e>] ? activate_task+0x3f/0=
x4e
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff81034fe5>] ?=20
>> try_to_wake_up+0x1eb/0x1f8
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff812eb768>] ?=20
>> netdev_drivername+0x3b/0x40
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0=
x1d6
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8102d1e3>] ? __wake_up+0x30/0x44
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff812fc9c7>] ? dev_watchdog+0x0/0x1=
d6
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff810448c4>] ?=20
>> run_timer_softirq+0x1ff/0x29d
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff810556ab>] ? ktime_get+0x5f/0xb7
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8103e0fd>] ? __do_softirq+0xd7/0x=
196
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8100be7c>] ? call_softirq+0x1c/0x=
28
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8100d645>] ? do_softirq+0x31/0x66
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8101b148>] ?=20
>> smp_apic_timer_interrupt+0x87/0x95
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8100b873>] ?=20
>> apic_timer_interrupt+0x13/0x20
>> Feb  4 13:12:40 TM_01_C1 <EOI>  [<ffffffff810111f5>] ?=20
>> mwait_idle+0x9b/0xa0
>> Feb  4 13:12:40 TM_01_C1 [<ffffffff8100a236>] ? cpu_idle+0x49/0x7c
>> Feb  4 13:12:40 TM_01_C1 ---[ end trace c670a6a17be040e5 ]---
>>
>> And after change kernel to 2.6.33-rc6 another different inf:
>>
>> BUG: soft lockup - CPU#1 stuck for 61s!
>> [events/1:28]
>> Modules linked in:
>> CPU 1
>> Pid: 28, comm: events/1 Not tainted 2.6.33-rc6-git5 #1 X7DCT/X7DCT
>> RIP: 0010:[<ffffffff810a3d89>]  [<ffffffff810a3d89>]
>> kmem_cache_free+0x11b/0x11c
>> RSP: 0018:ffff880028243e50  EFLAGS: 00000292
>> RAX: 0000000000000032 RBX: 000000000000007d RCX: ffff8803190683c0
>> RDX: 0000000000000031 RSI: ffff8803190683c0 RDI: ffff88031f83e680
>> RBP: ffffffff81002893 R08: 0000000000000000 R09: 000000000000007c
>> R10: ffff88030d776800 R11: ffff88030d7768a0 R12: ffff880028243dd0
>> R13: ffffc900008b2f80 R14: ffff88031fa7c800 R15: ffffffff81012da7
>> FS:  0000000000000000(0000) GS:ffff880028240000(0000)=20
>> knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> CR2: 00007fd61d5bd000 CR3: 000000031e55c000 CR4: 00000000000006a0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process events/1 (pid: 28, threadinfo ffff88031f9c8000, task=20
>> ffff88031f9a4f80)
>> Stack:
>>  ffffffff8126826f ffff88031faa4600 ffffffff8126834a 000096ba00000023
>> <0>  01ffc90000000024 ffff88031fbb4000 ffff88031faa4600 000000000000=
0040
>> <0>  0000000000000040 ffff88031faa4788 ffff88031faa4600 000000000000=
0740
>> Call Trace:
>> <IRQ>
>>  [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
>>  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
>>  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
>>  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
>>  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
>>  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>>  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>>  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>> <EOI>
>>  [<ffffffff81004599>] ? do_softirq+0x31/0x63
>>  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
>>  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>>  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
>>  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
>>  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
>>  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
>>  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
>>  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
>>  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
>>  [<ffffffff810479bd>] ? kthread+0x79/0x81
>>  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
>>  [<ffffffff81047944>] ? kthread+0x0/0x81
>>  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
>> Code: fe 79 4c 00 48 85 db 74 14 48 8b 74 24 10 48 89 ef ff 13 48 83=
=20
>> c3 08 48
>> 83 3b 00 eb ea 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f<c3>  55 48=20
>> 89 f5 53 48
>> 89 fb 48 83 ec 08 48 8b 76 18 48 2b 75 10
>> Call Trace:
>> <IRQ>   [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
>>  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
>>  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
>>  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
>>  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
>>  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>>  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>>  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>> <EOI>   [<ffffffff81004599>] ? do_softirq+0x31/0x63
>>  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
>>  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>>  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
>>  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
>>  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
>>  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
>>  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
>>  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
>>  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
>>  [<ffffffff810479bd>] ? kthread+0x79/0x81
>>  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
>>  [<ffffffff81047944>] ? kthread+0x0/0x81
>>
>>
>>  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
>>
>>
>>
> And other weird thing is that when i make affinity for nics and i bin=
d=20
> eth0 to cpu0 and eth1 to cpu2 i think i have too much cpu load:
> mpstat -P ALL 1 10
> Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft =20
> %steal  %guest   %idle
> Average:     all    0.00    0.00    0.00    0.10    1.63   16.71   =20
> 0.00    0.00   81.56
> Average:       0    0.00    0.00    0.00    0.00    5.10   72.80   =20
> 0.00    0.00   22.10
> Average:       1    0.00    0.00    0.00    0.00    0.00    0.00   =20
> 0.00    0.00  100.00
> Average:       2    0.00    0.00    0.00    0.00    8.00   61.00   =20
> 0.00    0.00   31.00
> Average:       3    0.00    0.00    0.00    0.00    0.00    0.00   =20
> 0.00    0.00  100.00
> Average:       4    0.00    0.00    0.00    0.00    0.00    0.00   =20
> 0.00    0.00  100.00
> Average:       5    0.00    0.00    0.00    0.00    0.00    0.00   =20
> 0.00    0.00  100.00
> Average:       6    0.00    0.00    0.00    0.70    0.00    0.00   =20
> 0.00    0.00   99.30
> Average:       7    0.00    0.00    0.00    0.00    0.00    0.00   =20
> 0.00    0.00  100.00
>
> As You see there is only 22% and 31% cpu idle
> With forwarded traffic like here:
>  bwm-ng v0.6 (probing every 3.000s), press 'h' for help
>   input: /proc/net/dev type: rate
>   -         iface                   Rx                  =20
> Tx                Total
>  =20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=20
>
>                lo:           0.00  b/s            0.00  b/s          =
 =20
> 0.00  b/s
>              eth0:         346.64 Mb/s          487.24 Mb/s         =20
> 833.88 Mb/s
>              eth1:         487.48 Mb/s          344.14 Mb/s         =20
> 831.61 Mb/s
>          vlan0811:         273.29 Mb/s          381.71 Mb/s         =20
> 655.01 Mb/s
>          vlan0508:          64.62 Mb/s          105.54 Mb/s         =20
> 170.15 Mb/s
>  =20
> ---------------------------------------------------------------------=
---------=20
>
>             total:           1.14 Gb/s            1.29 Gb/s          =
 =20
> 2.43 Gb/s
>
>
>
Ok i forget to add that on this router there is traffic management:
tc -s -d filter show dev eth1 | grep flowid | wc -l
9096
tc -s -d filter show dev vlan0811 | grep flowid | wc -l
9096

Those are iproute hashing filters.


Without filters on interfaces i have 50% idle. - so iproute traffic=20
management take 30% of cpu more.


>
>>
>>>
>>>
>>> --=20
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

