From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 11:45:43 +0200
Message-ID: <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
 <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:35503 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751549AbdITJrx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 05:47:53 -0400
In-Reply-To: <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok looks like ending bisection


Latest bisected kernel when there is no kernel panic 4.12.0+ (from 
next)  - but only this warning:

[  309.030019] NETDEV WATCHDOG: enp4s0f0 (ixgbe): transmit queue 0 timed out
[  309.030034] ------------[ cut here ]------------
[  309.030040] WARNING: CPU: 35 PID: 0 at dev_watchdog+0xcf/0x139
[  309.030041] Modules linked in: bonding ipmi_si x86_pkg_temp_thermal
[  309.030045] CPU: 35 PID: 0 Comm: swapper/35 Not tainted 4.12.0+ #5
[  309.030046] task: ffff88086d98a000 task.stack: ffffc90003378000
[  309.030048] RIP: 0010:dev_watchdog+0xcf/0x139
[  309.030049] RSP: 0018:ffff88087fbc3ea8 EFLAGS: 00010246
[  309.030050] RAX: 000000000000003d RBX: ffff88046b680000 RCX: 
0000000000000000
[  309.030050] RDX: ffff88087fbd2f01 RSI: 0000000000000000 RDI: 
ffff88087fbcda08
[  309.030051] RBP: ffff88087fbc3eb8 R08: 0000000000000000 R09: 
ffff88087ff80a04
[  309.030051] R10: 0000000000000000 R11: ffff88086d98a001 R12: 
0000000000000000
[  309.030052] R13: ffff88087fbc3ef8 R14: ffff88086d98a000 R15: 
ffffffff81c06008
[  309.030053] FS:  0000000000000000(0000) GS:ffff88087fbc0000(0000) 
knlGS:0000000000000000
[  309.030054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  309.030054] CR2: 00007fba600f6098 CR3: 000000086b955000 CR4: 
00000000001406e0
[  309.030055] Call Trace:
[  309.030057]  <IRQ>
[  309.030059]  ? netif_tx_lock+0x79/0x79
[  309.030062]  call_timer_fn.isra.24+0x17/0x77
[  309.030063]  run_timer_softirq+0x118/0x161
[  309.030065]  ? netif_tx_lock+0x79/0x79
[  309.030066]  ? ktime_get+0x2b/0x42
[  309.030070]  ? lapic_next_deadline+0x21/0x27
[  309.030073]  ? clockevents_program_event+0xa8/0xc5
[  309.030076]  __do_softirq+0xa8/0x19d
[  309.030078]  irq_exit+0x5d/0x6b
[  309.030079]  smp_apic_timer_interrupt+0x2a/0x36
[  309.030082]  apic_timer_interrupt+0x89/0x90
[  309.030085] RIP: 0010:mwait_idle+0x4e/0x6a
[  309.030086] RSP: 0018:ffffc9000337be98 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff10
[  309.030087] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 
0000000000000000
[  309.030087] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff88086d98a000
[  309.030088] RBP: ffffc9000337be98 R08: ffff88046f8279a0 R09: 
ffff88046f827040
[  309.030089] R10: ffff88086d98a000 R11: ffff88086d98a000 R12: 
0000000000000000
[  309.030089] R13: ffff88086d98a000 R14: ffff88086d98a000 R15: 
ffff88086d98a000
[  309.030090]  </IRQ>
[  309.030094]  arch_cpu_idle+0xa/0xc
[  309.030095]  default_idle_call+0x19/0x1b
[  309.030102]  do_idle+0xbc/0x196
[  309.030104]  cpu_startup_entry+0x1d/0x20
[  309.030105]  start_secondary+0xd8/0xdc
[  309.030108]  secondary_startup_64+0x9f/0x9f
[  309.030109] Code: cc 75 bd eb 35 48 89 df c6 05 c3 dc 74 00 01 e8 3a 
62 fe ff 44 89 e1 48 89 de 48 89 c2 48 c7 c7 0f 65 a4 81 31 c0 e8 3d 4c 
b5 ff <0f> ff 48 8b 83 e0 01 00 00 48 89 df ff 50 78 48 8b 05 a0 bc 6a
[  309.030128] ---[ end trace 9102cb25703ae2d9 ]---


I just marked it as good - cause this problem above is differend - and 
im going to:

git bisect good
Bisecting: 1787 revisions left to test after this (roughly 11 steps)




W dniu 2017-09-20 o 10:44, Paweł Staszewski pisze:
> Trying to make video from ipmi :)
>
> with that results:
>
> https://bugzilla.kernel.org/attachment.cgi?id=258521
>
> catched two more lines where it starts - panic from 4.13.2.
>
>
> Now will try tro do some bisection
>
>
>
> W dniu 2017-09-20 o 09:58, Paweł Staszewski pisze:
>> Hi
>>
>>
>> Will try bisecting tonight
>>
>>
>>
>> W dniu 2017-09-20 o 05:24, Eric Dumazet pisze:
>>> On Wed, 2017-09-20 at 02:06 +0200, Paweł Staszewski wrote:
>>>> Just checked kernel 4.13.2 and same problem
>>>>
>>>> Just after start all 6 bgp sessions - and kernel starts to learn 
>>>> routes
>>>> it panic.
>>>>
>>>> https://bugzilla.kernel.org/attachment.cgi?id=258509
>>>>
>>>
>>> Unfortunately we have not enough information from these traces.
>>>
>>> Can you get a full stack trace ?
>>>
>>> Alternatively, can you bisect ?
>>>
>>> Thanks.
>>>
>>>
>>>
>>
>>
>
>
