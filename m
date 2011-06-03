From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Fri, 03 Jun 2011 23:15:09 +0200
Message-ID: <4DE94EDD.8090707@free.fr>
References: <4DDE1B7D.7080707@free.fr> <1306403308.1200.44.camel@twins>	 <alpine.DEB.2.02.1105261217240.5114@localhost6.localdomain6>	 <4DDE7BEB.1050507@free.fr> <1306426675.2497.84.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:60700 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756464Ab1FCVPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 17:15:18 -0400
In-Reply-To: <1306426675.2497.84.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/05/2011 18:17, Peter Zijlstra a =C3=A9crit :
> On Thu, 2011-05-26 at 18:12 +0200, Laurent Riffard wrote:
>> Le 26/05/2011 12:35, Laurent Riffard a =C3=A9crit :
>>> On Thu, 26 May 2011, Peter Zijlstra wrote:
>>>> On Thu, 2011-05-26 at 11:21 +0200, Laurent Riffard wrote:
>>>>> Hi,
>>>>>
>>>>> Recently, netconsole was broken by some scheduler updates. Kernel=
 hangs
>>>>> on boot near the network card initialization. I noticed that it d=
oes
>>>>> hang just where a "inconsistent lock state" message normally appe=
ars.
>>>>>
>>>>> I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is t=
he
>>>>> first bad commit.
>>>>> commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
>>>>> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>>>> Date:   Tue Apr 5 17:23:54 2011 +0200
>>>>>
>>>>>     sched: Remove rq->lock from the first half of ttwu()
>>>>>
>>>>>
>>>>> Before this commit, kernel was booting succesfully despite the
>>>>> "inconsistent lock state" message. After this commit, the kernel =
does
>>>>> hang on boot, I have to push the reset button.
>>>>
>>>> Do you have CONFIG_HARDLOCKUP_DETECTOR=3Dy, and do you get an NMI =
splat
>>>> after some 10 seconds? It would be interesting to see where its st=
uck.
>>>
>>> CONFIG_HARDLOCKUP_DETECTOR is not set for now. I'll give it a try.
>>
>> I activated CONFIG_HARDLOCKUP_DETECTOR, but failed to obtain more=20
>> information. During the boot, the kernel hangs just after bringing u=
p=20
>> the NIC. I waited 2 minutes, without getting any more messages.
>=20
> OK, thanks for trying, I shall try and reproduce locally.
>=20

Hello,

I tried some newer kernel. It boots successfully now, but=20
I've got interesting (?) logs :

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.0.0-rc1-00049-g1fa7b6a (laurent@calimero=
) (gcc version 4.5.2 (Ubuntu/Linaro 4.5.2-8ubuntu4) ) #148 SMP PREEMPT =
Thu Jun 2 18:56:41 CEST 2011
[    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.0.0-rc1-00049-g1fa=
7b6a root=3D/dev/mapper/vglinux1-lv_ubuntu_64bits ro debug netconsole=3D=
4444@192.168.0.9/eth0,6666@192.168.0.10/6C:62:6D:48:4B:C7 splash vt.han=
doff=3D7
[...]
[    0.685768] Console: switching to colour frame buffer device 160x64
[    0.707611] fb0: VESA VGA frame buffer device
[    0.714029] Linux agpgart interface v0.103
[    0.714206] forcedeth: Reverse Engineered nForce ethernet driver. Ve=
rsion 0.64.
[    0.714837] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 23
[    0.715054] forcedeth 0000:00:0a.0: PCI INT A -> Link[APCH] -> GSI 2=
3 (level, low) -> IRQ 23
[    0.715283] forcedeth 0000:00:0a.0: setting latency timer to 64
[    1.241552] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 1, =
addr 00:1f:d0:53:49:ae
[    1.241784] forcedeth 0000:00:0a.0: highdma pwrctl mgmt gbit lnktim =
msi desc-v3
[    1.242101] netconsole: local port 4444
[    1.242207] netconsole: local IP 192.168.0.9
[    1.242320] netconsole: interface 'eth0'
[    1.242426] netconsole: remote port 6666
[    1.242531] netconsole: remote IP 192.168.0.10
[    1.242650] netconsole: remote ethernet address 6c:62:6d:48:4b:c7
[    1.242822] netconsole: device eth0 not up yet, forcing it
[    1.244612] forcedeth 0000:00:0a.0: irq 40 for MSI/MSI-X
[    1.245057] forcedeth 0000:00:0a.0: eth0: no link during initializat=
ion
[    2.374451] forcedeth 0000:00:0a.0: eth0: link up
[    2.381178]
[    2.381179] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    2.381182] [ INFO: inconsistent lock state ]
[    2.381184] 3.0.0-rc1-00049-g1fa7b6a #148
[    2.381186] ---------------------------------
[    2.381188] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[    2.381191] swapper/1 [HC0[0]:SC0[0]:HE1:SE1] takes:
[    2.381193]  (&(&napi->poll_lock)->rlock){+.?...}, at: [<ffffffff812=
3cd08>] netpoll_poll_dev+0x9d/0x4ed
[    2.381202] {IN-SOFTIRQ-W} state was registered at:
[    2.381204]   [<ffffffff81068020>] __lock_acquire+0x319/0xdd8
[    2.381208]   [<ffffffff81068f9f>] lock_acquire+0xd8/0x103
[    2.381211]   [<ffffffff8129c019>] _raw_spin_lock+0x36/0x45
[    2.381215]   [<ffffffff8122b886>] net_rx_action+0x8d/0x1e7
[    2.381219]   [<ffffffff81040f73>] __do_softirq+0xe1/0x1c0
[    2.381223]   [<ffffffff8129e39c>] call_softirq+0x1c/0x30
[    2.381226]   [<ffffffff81004296>] do_softirq+0x46/0x9c
[    2.381229]   [<ffffffff810412c5>] irq_exit+0x4d/0xa2
[    2.381232]   [<ffffffff81003f3a>] do_IRQ+0x88/0x9f
[    2.381235]   [<ffffffff8129cb93>] ret_from_intr+0x0/0x1a
[    2.381239]   [<ffffffff8100972c>] default_idle+0x40/0x74
[    2.381242]   [<ffffffff81009844>] amd_e400_idle+0xe4/0xe6
[    2.381246]   [<ffffffff81001270>] cpu_idle+0x5e/0x94
[    2.381249]   [<ffffffff81296383>] start_secondary+0x18a/0x18f
[    2.381252] irq event stamp: 1000341
[    2.381254] hardirqs last  enabled at (1000341): [<ffffffff8129cc58>=
] restore_args+0x0/0x30
[    2.381257] hardirqs last disabled at (1000339): [<ffffffff8104100a>=
] __do_softirq+0x178/0x1c0
[    2.381261] softirqs last  enabled at (1000340): [<ffffffff8104103c>=
] __do_softirq+0x1aa/0x1c0
[    2.381264] softirqs last disabled at (1000251): [<ffffffff8129e39c>=
] call_softirq+0x1c/0x30
[    2.381267]
[    2.381268] other info that might help us debug this:
[    2.381269]  Possible unsafe locking scenario:
[    2.381270]
[    2.381271]        CPU0
[    2.381272]        ----
[    2.381273]   lock(&(&napi->poll_lock)->rlock);
[    2.381275]   <Interrupt>
[    2.381276]     lock(&(&napi->poll_lock)->rlock);
[    2.381279]
[    2.381279]  *** DEADLOCK ***
[    2.381280]
[    2.381282] 1 lock held by swapper/1:
[    2.381283]  #0:  (target_list_lock){+.+...}, at: [<ffffffff811e5877=
>] write_msg+0x34/0xcd
[    2.381288]
[    2.381289] stack backtrace:
[    2.381291] Pid: 1, comm: swapper Not tainted 3.0.0-rc1-00049-g1fa7b=
6a #148
[    2.381293] Call Trace:
[    2.381297]  [<ffffffff81067b1d>] valid_state+0x217/0x229
[    2.381300]  [<ffffffff81067396>] ? check_usage_forwards+0x85/0x85
[    2.381303]  [<ffffffff81067c11>] mark_lock+0xe2/0x1d8
[    2.381306]  [<ffffffff810693bb>] ? trace_hardirqs_on_caller+0x10b/0=
x12f
[    2.381309]  [<ffffffff8106809e>] __lock_acquire+0x397/0xdd8
[    2.381314]  [<ffffffff8106e882>] ? arch_local_irq_restore+0x6/0xd
[    2.381317]  [<ffffffff8123cd08>] ? netpoll_poll_dev+0x9d/0x4ed
[    2.381320]  [<ffffffff81068f9f>] lock_acquire+0xd8/0x103
[    2.381324]  [<ffffffff8123cd08>] ? netpoll_poll_dev+0x9d/0x4ed
[    2.381327]  [<ffffffff8129c557>] _raw_spin_trylock+0x4a/0x7f
[    2.381331]  [<ffffffff8123cd08>] ? netpoll_poll_dev+0x9d/0x4ed
[    2.381334]  [<ffffffff8123cd08>] netpoll_poll_dev+0x9d/0x4ed
[    2.381338]  [<ffffffff8123d2ee>] netpoll_send_skb_on_dev+0x10b/0x20=
f
[    2.381342]  [<ffffffff8123d5dd>] netpoll_send_udp+0x1eb/0x1fa
[    2.381345]  [<ffffffff811e5877>] ? write_msg+0x34/0xcd
[    2.381348]  [<ffffffff811e58cf>] write_msg+0x8c/0xcd
[    2.381352]  [<ffffffff8103b78d>] __call_console_drivers+0x72/0x84
[    2.381355]  [<ffffffff8103b7f8>] _call_console_drivers+0x59/0x5e
[    2.381359]  [<ffffffff8103c033>] console_unlock+0xf3/0x1ac
[    2.381362]  [<ffffffff8103c891>] register_console+0x228/0x2b3
[    2.381366]  [<ffffffff816a76b0>] init_netconsole+0x15d/0x1e4
[    2.381371]  [<ffffffff81166a64>] ? __pci_register_driver+0x9b/0xcd
[    2.381374]  [<ffffffff816a7553>] ? option_setup+0x1f/0x1f
[    2.381377]  [<ffffffff8100030f>] do_one_initcall+0x7a/0x137
[    2.381381]  [<ffffffff81685bcd>] kernel_init+0xb5/0x135
[    2.381386]  [<ffffffff81157d1e>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[    2.381389]  [<ffffffff8129e2a4>] kernel_thread_helper+0x4/0x10
[    2.381392]  [<ffffffff8129cc58>] ? retint_restore_args+0x13/0x13
[    2.381396]  [<ffffffff81685b18>] ? start_kernel+0x360/0x360
[    2.381399]  [<ffffffff8129e2a0>] ? gs_change+0x13/0x13
[    2.381464] ------------[ cut here ]------------
[    2.381468] WARNING: at net/core/netpoll.c:346 netpoll_send_skb_on_d=
ev+0x158/0x20f()
[    2.381470] Hardware name: M68SM-S2L
[    2.381473] netpoll_send_skb(): eth0 enabled interrupts in poll (nv_=
start_xmit_optimized+0x0/0x484)
[    2.381474] Modules linked in:
[    2.381477] Pid: 1, comm: swapper Not tainted 3.0.0-rc1-00049-g1fa7b=
6a #148
[    2.381479] Call Trace:
[    2.381482]  [<ffffffff8103b381>] warn_slowpath_common+0x80/0x98
[    2.381485]  [<ffffffff8103b42d>] warn_slowpath_fmt+0x41/0x43
[    2.381489]  [<ffffffff811e526c>] ? nv_start_xmit+0x3df/0x3df
[    2.381492]  [<ffffffff8123d33b>] netpoll_send_skb_on_dev+0x158/0x20=
f
[    2.381496]  [<ffffffff8123d5dd>] netpoll_send_udp+0x1eb/0x1fa
[    2.381499]  [<ffffffff811e5877>] ? write_msg+0x34/0xcd
[    2.381502]  [<ffffffff811e58cf>] write_msg+0x8c/0xcd
[    2.381505]  [<ffffffff8103b78d>] __call_console_drivers+0x72/0x84
[    2.381508]  [<ffffffff8103b7f8>] _call_console_drivers+0x59/0x5e
[    2.381512]  [<ffffffff8103c033>] console_unlock+0xf3/0x1ac
[    2.381515]  [<ffffffff8103c891>] register_console+0x228/0x2b3
[    2.381518]  [<ffffffff816a76b0>] init_netconsole+0x15d/0x1e4
[    2.381522]  [<ffffffff81166a64>] ? __pci_register_driver+0x9b/0xcd
[    2.381525]  [<ffffffff816a7553>] ? option_setup+0x1f/0x1f
[    2.381528]  [<ffffffff8100030f>] do_one_initcall+0x7a/0x137
[    2.381531]  [<ffffffff81685bcd>] kernel_init+0xb5/0x135
[    2.381535]  [<ffffffff81157d1e>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[    2.381538]  [<ffffffff8129e2a4>] kernel_thread_helper+0x4/0x10
[    2.381541]  [<ffffffff8129cc58>] ? retint_restore_args+0x13/0x13
[    2.381545]  [<ffffffff81685b18>] ? start_kernel+0x360/0x360
[    2.381548]  [<ffffffff8129e2a0>] ? gs_change+0x13/0x13
[    2.381555] ---[ end trace f00f2127e552114f ]---
[    2.383979] console [netcon0] enabled
[    2.384117] netconsole: network logging started
[    2.384492] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 =
irq 1
[    2.384679] i8042: PNP: PS/2 appears to have AUX port disabled, if t=
his is incorrect please boot with i8042.nopnp
[    2.385208] serio: i8042 KBD port at 0x60,0x64 irq 1
[...]
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


hope this help
~~
laurent

