From: sbs <gexlie@gmail.com>
Subject: Re: Panic at tcp_xmit_retransmit_queue
Date: Mon, 1 Feb 2010 17:45:38 +0300
Message-ID: <53cc795f1002010645w54b98b51s3dbdea18e5eb73f2@mail.gmail.com>
References: <53cc795f1001190813m377c6c91l16b2dc04f63049e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53cc795f1001190813m377c6c91l16b2dc04f63049e7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

actually removing netconsole from kernel didnt help.
i found many guys with the same problem but with different hardware
configurations here:

freez in TCP stack :
http://bugzilla.kernel.org/show_bug.cgi?id=3D14470

is there someone who can investigate it?


On Tue, Jan 19, 2010 at 7:13 PM, sbs <gexlie@gmail.com> wrote:
> We are hiting kernel panics on servers with nVidia MCP55 NICs once a =
day;
> it appears usualy under a high network trafic ( around 10000Mbit/s) b=
ut
> it is not a rule, it has happened even on low trafic.
>
> Servers are used as nginx+static content
> On 2 equal servers this panic happens aprox 2 times a day depending o=
n
> network load. Machine completly freezes till the netconsole reboots.
>
> Kernel: 2.6.32.3
>
> what can it be? whats wrong with tcp_xmit_retransmit_queue() function=
 ?
> can anyone explain or fix?
>
> Panic output:
>
> Dec 29 22:33:51 linuxtest [1188725.037019] BUG: unable to handle kern=
el
> Dec 29 22:33:51 linuxtest NULL pointer dereference
> Dec 29 22:33:51 linuxtest at (null)
> Dec 29 22:33:51 linuxtest [1188725.037042] IP:
> Dec 29 22:33:51 linuxtest [<c060164a>] tcp_xmit_retransmit_queue+0x1b=
2/0x1dc
> Dec 29 22:33:51 linuxtest [1188725.037064] *pdpt =3D 00000000229c2001
> Dec 29 22:33:51 linuxtest *pde =3D 0000000000000000
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.037080] Thread overran stack, or
> stack corrupted
> Dec 29 22:33:51 linuxtest [1188725.037091] Oops: 0000 [#1]
> Dec 29 22:33:51 linuxtest SMP
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.037104] last sysfs file:
> /sys/devices/pci0000:00/0000:00:0f.0/0000:07:00.0/0000:08:01.0/0000:0=
9:00.0/class
> Dec 29 22:33:51 linuxtest [1188725.037124]
> Dec 29 22:33:51 linuxtest [1188725.037131] Pid: 0, comm: swapper Not
> tainted (2.6.31.6-v03 #2) H8DMU
> Dec 29 22:33:51 linuxtest [1188725.037145] EIP: 0060:[<c060164a>]
> EFLAGS: 00010246 CPU: 0
> Dec 29 22:33:51 linuxtest [1188725.037158] EIP is at
> tcp_xmit_retransmit_queue+0x1b2/0x1dc
> Dec 29 22:33:51 linuxtest [1188725.037170] EAX: c540513c EBX: c54050c=
0
> ECX: 0e377f15 EDX: c540513c
> Dec 29 22:33:51 linuxtest [1188725.037183] ESI: 00000000 EDI: 0000000=
0
> EBP: c0805d28 ESP: c0805d0c
> Dec 29 22:33:51 linuxtest [1188725.037196] =A0DS: 007b ES: 007b FS: 0=
0d8
> GS: 0000 SS: 0068
> Dec 29 22:33:51 linuxtest [1188725.037208] Process swapper (pid: 0,
> ti=3Dc0804000 task=3Dc080b5a0 task.ti=3Dc0804000)
> Dec 29 22:33:51 linuxtest [1188725.037285] Stack:
> Dec 29 22:33:51 linuxtest [1188725.037368] =A000000202
> Dec 29 22:33:51 linuxtest 00000000
> Dec 29 22:33:51 linuxtest c540513c
> Dec 29 22:33:51 linuxtest 0e377f14
> Dec 29 22:33:51 linuxtest 00000000
> Dec 29 22:33:51 linuxtest c54050c0
> Dec 29 22:33:51 linuxtest 0000050e
> Dec 29 22:33:51 linuxtest c0805da8
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.037472] <0>
> Dec 29 22:33:51 linuxtest c05fe931
> Dec 29 22:33:51 linuxtest 00000001
> Dec 29 22:33:51 linuxtest 00000001
> Dec 29 22:33:51 linuxtest 00000006
> Dec 29 22:33:51 linuxtest 00000005
> Dec 29 22:33:51 linuxtest 00000001
> Dec 29 22:33:51 linuxtest 00000001
> Dec 29 22:33:51 linuxtest 00000006
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.037629] <0>
> Dec 29 22:33:51 linuxtest 01000246
> Dec 29 22:33:51 linuxtest 00000005
> Dec 29 22:33:51 linuxtest 11b57b53
> Dec 29 22:33:51 linuxtest c5405168
> Dec 29 22:33:51 linuxtest c061df41
> Dec 29 22:33:51 linuxtest 00000006
> Dec 29 22:33:51 linuxtest 00000000
> Dec 29 22:33:51 linuxtest 00000000
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.037887] Call Trace:
> Dec 29 22:33:51 linuxtest [1188725.037975] =A0[<c05fe931>] ? tcp_ack+=
0x1591/0x1778
> Dec 29 22:33:51 linuxtest [1188725.038073] =A0[<c061df41>] ?
> ipt_do_table+0x2f8/0x310
> Dec 29 22:33:51 linuxtest [1188725.038148] =A0[<c05ff493>] ?
> tcp_rcv_state_process+0x4db/0x7fc
> Dec 29 22:33:51 linuxtest [1188725.038246] =A0[<c0604e3d>] ?
> tcp_v4_do_rcv+0x263/0x29d
> Dec 29 22:33:51 linuxtest [1188725.038321] =A0[<c023381a>] ?
> local_bh_enable+0xb/0xd
> Dec 29 22:33:51 linuxtest [1188725.038419] =A0[<c05d4571>] ? sk_filte=
r+0x5e/0x69
> Dec 29 22:33:51 linuxtest [1188725.038510] =A0[<c06059b4>] ?
> tcp_v4_rcv+0x371/0x502
> Dec 29 22:33:51 linuxtest [1188725.038607] =A0[<c05ee78c>] ?
> ip_local_deliver_finish+0x0/0x171
> Dec 29 22:33:51 linuxtest [1188725.038684] =A0[<c05ee88a>] ?
> ip_local_deliver_finish+0xfe/0x171
> Dec 29 22:33:51 linuxtest [1188725.038784] =A0[<c05ee95e>] ?
> ip_local_deliver+0x61/0x66
> Dec 29 22:33:51 linuxtest [1188725.038876] =A0[<c05ee531>] ?
> ip_rcv_finish+0x289/0x2b1
> Dec 29 22:33:51 linuxtest [1188725.038961] =A0[<c05ee75c>] ? ip_rcv+0=
x203/0x233
> Dec 29 22:33:51 linuxtest [1188725.039052] =A0[<c05ca149>] ?
> netif_receive_skb+0x335/0x350
> Dec 29 22:33:51 linuxtest [1188725.039151] =A0[<c05ca1c6>] ?
> process_backlog+0x62/0x88
> Dec 29 22:33:51 linuxtest [1188725.039242] =A0[<c05ca6c5>] ?
> net_rx_action+0x8e/0x16b
> Dec 29 22:33:51 linuxtest [1188725.039333] =A0[<c02335bb>] ?
> __do_softirq+0xa7/0x148
> Dec 29 22:33:51 linuxtest [1188725.039423] =A0[<c0233682>] ? do_softi=
rq+0x26/0x2b
> Dec 29 22:33:51 linuxtest [1188725.039520] =A0[<c0233764>] ? irq_exit=
+0x29/0x5c
> Dec 29 22:33:51 linuxtest [1188725.039610] =A0[<c0204365>] ? do_IRQ+0=
x81/0x95
> Dec 29 22:33:51 linuxtest [1188725.039706] =A0[<c0202ec9>] ?
> common_interrupt+0x29/0x30
> Dec 29 22:33:51 linuxtest [1188725.039797] =A0[<c0208b74>] ?
> default_idle+0x3e/0x5b
> Dec 29 22:33:51 linuxtest [1188725.039895] =A0[<c02479c9>] ?
> clockevents_notify+0x60/0x65
> Dec 29 22:33:51 linuxtest [1188725.039986] =A0[<c0208c49>] ? c1e_idle=
+0xb8/0xd2
> Dec 29 22:33:51 linuxtest [1188725.040058] =A0[<c0201bba>] ? cpu_idle=
+0x45/0x5f
> Dec 29 22:33:51 linuxtest [1188725.040131] =A0[<c0643560>] ? rest_ini=
t+0x58/0x5a
> Dec 29 22:33:51 linuxtest [1188725.040212] =A0[<c084f7f9>] ?
> start_kernel+0x2f0/0x2f5
> Dec 29 22:33:51 linuxtest [1188725.040285] =A0[<c084f070>] ?
> i386_start_kernel+0x70/0x77
> Dec 29 22:33:51 linuxtest [1188725.040381] Code:
> Dec 29 22:33:51 linuxtest ec
> Dec 29 22:33:51 linuxtest bd
> Dec 29 22:33:51 linuxtest 84
> Dec 29 22:33:51 linuxtest c0
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest 04
> Dec 29 22:33:51 linuxtest 88
> Dec 29 22:33:51 linuxtest 8b
> Dec 29 22:33:51 linuxtest 55
> Dec 29 22:33:51 linuxtest ec
> Dec 29 22:33:51 linuxtest 8b
> Dec 29 22:33:51 linuxtest 02
> Dec 29 22:33:51 linuxtest 39
> Dec 29 22:33:51 linuxtest d0
> Dec 29 22:33:51 linuxtest ba
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 0f
> Dec 29 22:33:51 linuxtest 44
> Dec 29 22:33:51 linuxtest c2
> Dec 29 22:33:51 linuxtest 39
> Dec 29 22:33:51 linuxtest c6
> Dec 29 22:33:51 linuxtest 75
> Dec 29 22:33:51 linuxtest 0f
> Dec 29 22:33:51 linuxtest 8b
> Dec 29 22:33:51 linuxtest 8b
> Dec 29 22:33:51 linuxtest 18
> Dec 29 22:33:51 linuxtest 02
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest b2
> Dec 29 22:33:51 linuxtest 01
> Dec 29 22:33:51 linuxtest 89
> Dec 29 22:33:51 linuxtest d8
> Dec 29 22:33:51 linuxtest e8
> Dec 29 22:33:51 linuxtest ee
> Dec 29 22:33:51 linuxtest fd
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest 8b
> Dec 29 22:33:51 linuxtest 36
> Dec 29 13:33:50 linuxtest unparseable log message: "<8b> "
> Dec 29 22:33:51 linuxtest 06
> Dec 29 22:33:51 linuxtest 0f
> Dec 29 22:33:51 linuxtest 18
> Dec 29 22:33:51 linuxtest 00
> Dec 29 22:33:51 linuxtest 90
> Dec 29 22:33:51 linuxtest 3b
> Dec 29 22:33:51 linuxtest 75
> Dec 29 22:33:51 linuxtest ec
> Dec 29 22:33:51 linuxtest 0f
> Dec 29 22:33:51 linuxtest 85
> Dec 29 22:33:51 linuxtest a9
> Dec 29 22:33:51 linuxtest fe
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest eb
> Dec 29 22:33:51 linuxtest 11
> Dec 29 22:33:51 linuxtest 85
> Dec 29 22:33:51 linuxtest ff
> Dec 29 22:33:51 linuxtest 0f
> Dec 29 22:33:51 linuxtest 84
> Dec 29 22:33:51 linuxtest
> Dec 29 22:33:51 linuxtest [1188725.040771] EIP: [<c060164a>]
> Dec 29 22:33:51 linuxtest tcp_xmit_retransmit_queue+0x1b2/0x1dc
> Dec 29 22:33:51 linuxtest SS:ESP 0068:c0805d0c
> Dec 29 22:33:51 linuxtest [1188725.040929] CR2: 0000000000000000
> Dec 29 22:33:51 linuxtest [1188725.041346] ---[ end trace 1b9e8ae01c5=
d5485 ]---
> Dec 29 22:33:51 linuxtest [1188725.042940] Kernel panic - not syncing=
:
> Fatal exception in interrupt
> Dec 29 22:33:51 linuxtest [1188725.043076] Pid: 0, comm: swapper
> Tainted: G =A0 =A0 =A0D =A0 =A02.6.31.6-v03 #2
> Dec 29 22:33:51 linuxtest [1188725.043188] Call Trace:
> Dec 29 22:33:51 linuxtest [1188725.043318] =A0[<c066812b>] ? printk+0=
xf/0x11
> Dec 29 22:33:51 linuxtest [1188725.043441] =A0[<c066807f>] panic+0x39=
/0xd6
> Dec 29 22:33:51 linuxtest [1188725.043558] =A0[<c0205811>] oops_end+0=
x8b/0x9a
> Dec 29 22:33:51 linuxtest [1188725.043683] =A0[<c021c974>] no_context=
+0x13c/0x146
> Dec 29 22:33:51 linuxtest [1188725.043814] =A0[<c021ca91>]
> __bad_area_nosemaphore+0x113/0x11b
> Dec 29 22:33:51 linuxtest [1188725.043943] =A0[<c0553967>] ?
> nv_start_xmit_optimized+0x3d4/0x401
> Dec 29 22:33:51 linuxtest [1188725.044073] =A0[<c02253b2>] ?
> __enqueue_entity+0x8d/0x95
> Dec 29 22:33:51 linuxtest [1188725.044182] =A0[<c021caa6>]
> bad_area_nosemaphore+0xd/0x10
> Dec 29 22:33:51 linuxtest [1188725.044319] =A0[<c021cce3>]
> do_page_fault+0x108/0x265
> Dec 29 22:33:51 linuxtest [1188725.044444] =A0[<c0223993>] ?
> enqueue_task+0x72/0x7f
> Dec 29 22:33:51 linuxtest [1188725.044562] =A0[<c021cbdb>] ?
> do_page_fault+0x0/0x265
> Dec 29 22:33:51 linuxtest [1188725.044686] =A0[<c0669b86>] error_code=
+0x66/0x6c
> Dec 29 22:33:51 linuxtest [1188725.044817] =A0[<c021cbdb>] ?
> do_page_fault+0x0/0x265
> Dec 29 22:33:51 linuxtest [1188725.044944] =A0[<c060164a>] ?
> tcp_xmit_retransmit_queue+0x1b2/0x1dc
> Dec 29 22:33:51 linuxtest [1188725.045077] =A0[<c05fe931>] tcp_ack+0x=
1591/0x1778
> Dec 29 22:33:51 linuxtest [1188725.045201] =A0[<c061df41>] ?
> ipt_do_table+0x2f8/0x310
> Dec 29 22:33:51 linuxtest [1188725.045332] =A0[<c05ff493>]
> tcp_rcv_state_process+0x4db/0x7fc
> Dec 29 22:33:51 linuxtest [1188725.045442] =A0[<c0604e3d>]
> tcp_v4_do_rcv+0x263/0x29d
> Dec 29 22:33:51 linuxtest [1188725.045567] =A0[<c023381a>] ?
> local_bh_enable+0xb/0xd
> Dec 29 22:33:51 linuxtest [1188725.045694] =A0[<c05d4571>] ? sk_filte=
r+0x5e/0x69
> Dec 29 22:33:51 linuxtest [1188725.045802] =A0[<c06059b4>] tcp_v4_rcv=
+0x371/0x502
> Dec 29 22:33:51 linuxtest [1188725.045911] =A0[<c05ee78c>] ?
> ip_local_deliver_finish+0x0/0x171
> Dec 29 22:33:51 linuxtest [1188725.046045] =A0[<c05ee88a>]
> ip_local_deliver_finish+0xfe/0x171
> Dec 29 22:33:51 linuxtest [1188725.046155] =A0[<c05ee95e>]
> ip_local_deliver+0x61/0x66
> Dec 29 22:33:51 linuxtest [1188725.046301] =A0[<c05ee531>]
> ip_rcv_finish+0x289/0x2b1
> Dec 29 22:33:51 linuxtest [1188725.046429] =A0[<c05ee75c>] ip_rcv+0x2=
03/0x233
> Dec 29 22:33:51 linuxtest [1188725.046555] =A0[<c05ca149>]
> netif_receive_skb+0x335/0x350
> Dec 29 22:33:51 linuxtest [1188725.046664] =A0[<c05ca1c6>]
> process_backlog+0x62/0x88
> Dec 29 22:33:51 linuxtest [1188725.046809] =A0[<c05ca6c5>]
> net_rx_action+0x8e/0x16b
> Dec 29 22:33:51 linuxtest [1188725.046917] =A0[<c02335bb>] __do_softi=
rq+0xa7/0x148
> Dec 29 22:33:51 linuxtest [1188725.047041] =A0[<c0233682>] do_softirq=
+0x26/0x2b
> Dec 29 22:33:51 linuxtest [1188725.047162] =A0[<c0233764>] irq_exit+0=
x29/0x5c
> Dec 29 22:33:51 linuxtest [1188725.047285] =A0[<c0204365>] do_IRQ+0x8=
1/0x95
> Dec 29 22:33:51 linuxtest [1188725.047409] =A0[<c0202ec9>]
> common_interrupt+0x29/0x30
> Dec 29 22:33:51 linuxtest [1188725.047536] =A0[<c0208b74>] ?
> default_idle+0x3e/0x5b
> Dec 29 22:33:51 linuxtest [1188725.047664] =A0[<c02479c9>] ?
> clockevents_notify+0x60/0x65
> Dec 29 22:33:51 linuxtest [1188725.047790] =A0[<c0208c49>] c1e_idle+0=
xb8/0xd2
> Dec 29 22:33:51 linuxtest [1188725.047913] =A0[<c0201bba>] cpu_idle+0=
x45/0x5f
> Dec 29 22:33:51 linuxtest [1188725.048030] =A0[<c0643560>] rest_init+=
0x58/0x5a
> Dec 29 22:33:51 linuxtest [1188725.048153] =A0[<c084f7f9>]
> start_kernel+0x2f0/0x2f5
> Dec 29 22:33:51 linuxtest [1188725.048271] =A0[<c084f070>]
> i386_start_kernel+0x70/0x77
> Dec 29 22:33:51 linuxtest [1188725.048404] Rebooting in 10 seconds..
>
