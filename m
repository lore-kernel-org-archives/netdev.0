From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 4.4-rc5 crash (af_unix)
Date: Mon, 21 Dec 2015 16:51:52 -0800
Message-ID: <CAM_iQpUuqL6KEnMn-z-WzB_wQPixch_r4EQtn4jpGWU7uNJEZg@mail.gmail.com>
References: <567395AB.40802@nextfour.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <567395AB.40802@nextfour.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and Rainer)

On Thu, Dec 17, 2015 at 9:12 PM, Mika Penttil=C3=A4
<mika.penttila@nextfour.com> wrote:
> Still something with af_unix and/or wake code on rc5 :
>
>
> [34971.300210] Unable to handle kernel paging request at virtual addr=
ess
> 56ac56ac
>
> [34971.307455] pgd =3D a8c30000
>
> [34971.310164] [56ac56ac] *pgd=3D00000000
>
> [34971.313761] Internal error: Oops: 80000005 [#1] PREEMPT SMP ARM
>
> [34971.319683] Modules linked in: btwilink st_drv
>
> [34971.324174] CPU: 1 PID: 333 Comm: compositor Not tainted 4.4.0-rc5=
 #1
>
> [34971.330620] Hardware name: Freescale i.MX6 Quad/DualLite (Device T=
ree)
>
> [34971.337152] task: a8c71c80 ti: a8aea000 task.ti: a8aea000
>
> [34971.342554] PC is at 0x56ac56ac
>
> [34971.345710] LR is at __wake_up_common+0x4c/0x80
>
> [34971.350246] pc : [<56ac56ac>]    lr : [<800585e4>]    psr: 200f009=
3
>
> [34971.350246] sp : a8aebd20  ip : a8ea56bc  fp : 00000001
>
> [34971.361725] r10: 00000001  r9 : 00000001  r8 : 00000304
>
> [34971.366952] r7 : a8ea5744  r6 : 8023a9e4  r5 : 56ac56ac  r4 : a8c9=
5d28
>
> [34971.373480] r3 : 00000304  r2 : 00000001  r1 : 00000001  r0 : a8ea=
56bc
>
> [34971.380010] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
> Segment user
>
> [34971.387234] Control: 10c5387d  Table: 38c3004a  DAC: 00000055
>
> [34971.392982] Process compositor (pid: 333, stack limit =3D 0xa8aea2=
10)
>
> [34971.399250] Stack: (0xa8aebd20 to 0xa8aec000)
>
> [34971.403612] bd20: 00000001 a8ea5740 00000001 00000304 00000001
> a00f0013 00000098 a8aebe4c
>
> [34971.411793] bd40: 00000000 80058bc8 00000304 a8aebe78 a8db42c0
> a8db42c0 a8db4000 00000f68
>
> [34971.419974] bd60: a8db4084 805bd7c0 a8db4394 805196d8 a9e37600
> 00000000 a8db4000 805bd270
>
> [34971.428155] bd80: a8aebd94 00000000 00000000 00000000 00000000
> 00000000 a9e37600 8051a810
>
> [34971.436336] bda0: a9e37600 8051a970 a9e37600 8051aa44 a9e37600
> 805be498 7ec113e8 8025f2e4
>
> [34971.444517] bdc0: a8f35044 00000098 a8db420c 00000098 a653e780
> 00000001 00000000 00000000
>
> [34971.452697] bde0: a8db41e4 00000000 a8aebdf8 00000000 a8aea000
> 800e4928 00000000 00000000
>
> [34971.460878] be00: 00000000 00000000 00000000 00000000 7ec115a8
> 80264d8c a8aebe78 a8aebe24
>
> [34971.469059] be20: 00a5cda4 80513658 a8aebf6c 40000040 7ec115b8
> 7ec115d4 a8aebeb8 a653e780
>
> [34971.477240] be40: 00c50388 805be604 00c87240 805bd130 a653e780
> a8aebf6c 00000000 00001000
>
> [34971.485420] be60: 40000040 00000000 00c50388 8051515c 00000000
> 00000000 00c506fc 00000c8c
>
> [34971.493601] be80: 00c50388 00000374 0000014d 00000000 00000004
> 00000320 00a70664 00983dcc
>
> [34971.501782] bea0: 758ce8e0 00983dcc 758ce8e0 758ce8ec 00a70664
> 758ce8ec 00000000 80513a8c
>
> [34971.509963] bec0: a8b6df8c a8aebf10 a8b6df8c a8aebf10 7ec116d8
> 8011da50 00a70664 00000000
>
> [34971.518143] bee0: 00000001 600f0013 a8aebefc 8004559c a8c07500
> 600f0013 a8c07534 806de1a0
>
> [34971.526324] bf00: a8c07534 806de414 00000000 8011df1c a8aebf10
> a8aebf10 a8aebf2c 00000020
>
> [34971.534505] bf20: a895ccc0 800fd364 a8aebf68 a8aebf64 40000040
> 00000129 a653e780 7ec115b8
>
> [34971.542686] bf40: 40000040 00000129 8000f6a4 a8aea000 00000000
> 80515eb0 00000000 00000000
>
> [34971.550867] bf60: 00000020 00000001 fffffff7 00000000 00000000
> 00000000 00000098 00000f68
>
> [34971.559047] bf80: a8aebe78 00000002 7ec115d4 0000007c 40000000
> 00000000 00000040 0000001c
>
> [34971.567227] bfa0: 7ec115b8 8000f500 00000040 0000001c 0000001c
> 7ec115b8 40000040 00000000
>
> [34971.575409] bfc0: 00000040 0000001c 7ec115b8 00000129 00000006
> 7ec115b8 76145d68 00c50388
>
> [34971.583589] bfe0: 00000000 7ec11588 73d6f4c0 75bef794 800f0010
> 0000001c 3bf5e861 3bf5ec61
>
> [34971.591782] [<800585e4>] (__wake_up_common) from [<80058bc8>]
> (__wake_up_sync_key+0x44/0x60)
>
> [34971.600235] [<80058bc8>] (__wake_up_sync_key) from [<805bd7c0>]
> (unix_write_space+0x58/0x88)
>
> [34971.608686] [<805bd7c0>] (unix_write_space) from [<805196d8>]
> (sock_wfree+0x78/0x80)
>
> [34971.616437] [<805196d8>] (sock_wfree) from [<805bd270>]
> (unix_destruct_scm+0x64/0x6c)
>
> [34971.624276] [<805bd270>] (unix_destruct_scm) from [<8051a810>]
> (skb_release_head_state+0x84/0xec)
>
> [34971.633154] [<8051a810>] (skb_release_head_state) from [<8051a970>=
]
> (skb_release_all+0xc/0x24)
>
> [34971.641772] [<8051a970>] (skb_release_all) from [<8051aa44>]
> (consume_skb+0x24/0x60)
>
> [34971.649523] [<8051aa44>] (consume_skb) from [<805be498>]
> (unix_stream_read_generic+0x71c/0x7d0)
>
> [34971.658228] [<805be498>] (unix_stream_read_generic) from [<805be60=
4>]
> (unix_stream_recvmsg+0x38/0x40)
>
> [34971.667453] [<805be604>] (unix_stream_recvmsg) from [<8051515c>]
> (___sys_recvmsg+0x94/0x12c)
>
> [34971.675897] [<8051515c>] (___sys_recvmsg) from [<80515eb0>]
> (__sys_recvmsg+0x3c/0x6c)
>
> [34971.683738] [<80515eb0>] (__sys_recvmsg) from [<8000f500>]
> (ret_fast_syscall+0x0/0x34)
>
> [34971.691659] Code: bad PC value
>
> [34971.694718] ---[ end trace b54a6d4b7a89f212 ]---
>
> [34971.699339] Kernel panic - not syncing: Fatal exception
>
> [34971.704572] CPU2: stopping
>
> [34971.707292] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D
> 4.4.0-rc5 #1
>
> [34971.714691] Hardware name: Freescale i.MX6 Quad/DualLite (Device T=
ree)
>
> [34971.721240] [<80016be4>] (unwind_backtrace) from [<80012b68>]
> (show_stack+0x10/0x14)
>
> [34971.728997] [<80012b68>] (show_stack) from [<802527f8>]
> (dump_stack+0x84/0xc4)
>
> [34971.736227] [<802527f8>] (dump_stack) from [<80015aa8>]
> (handle_IPI+0x1ac/0x1c0)
>
> [34971.743630] [<80015aa8>] (handle_IPI) from [<80009468>]
> (gic_handle_irq+0x84/0x88)
>
> [34971.751206] [<80009468>] (gic_handle_irq) from [<80013600>]
> (__irq_svc+0x40/0x74)
>
> [34971.758691] Exception stack(0xa80a3f58 to 0xa80a3fa0)
>
> [34971.763745] 3f40:
>    00000000 ab720d00
>
> [34971.771927] 3f60: 00000001 a80a2000 00000001 ab71d528 9166621b
> 00001fce 9006c93e 00001fce
>
> [34971.780109] 3f80: 00000004 80b635e8 00000000 a80a3fa8 806de3c0
> 8046687c 20000013 ffffffff
>
> [34971.788299] [<80013600>] (__irq_svc) from [<8046687c>]
> (cpuidle_enter_state+0x128/0x25c)
>
> [34971.796400] [<8046687c>] (cpuidle_enter_state) from [<8005917c>]
> (cpu_startup_entry+0x18c/0x270)
>
> [34971.805193] [<8005917c>] (cpu_startup_entry) from [<1000950c>]
> (0x1000950c)
>
> [34971.812157] CPU0: stopping
>
> [34971.814874] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D
> 4.4.0-rc5 #1
>
> [34971.822273] Hardware name: Freescale i.MX6 Quad/DualLite (Device T=
ree)
>
> [34971.828815] [<80016be4>] (unwind_backtrace) from [<80012b68>]
> (show_stack+0x10/0x14)
>
> [34971.836567] [<80012b68>] (show_stack) from [<802527f8>]
> (dump_stack+0x84/0xc4)
>
> [34971.843797] [<802527f8>] (dump_stack) from [<80015aa8>]
> (handle_IPI+0x1ac/0x1c0)
>
> [34971.851200] [<80015aa8>] (handle_IPI) from [<80009468>]
> (gic_handle_irq+0x84/0x88)
>
> [34971.858775] [<80009468>] (gic_handle_irq) from [<80013600>]
> (__irq_svc+0x40/0x74)
>
> [34971.866260] Exception stack(0x80b61f20 to 0x80b61f68)
>
> [34971.871318] 1f20: 00000000 ab708d00 00000001 80b60000 00000001
> ab705528 91666267 00001fce
>
> [34971.879500] 1f40: 9006a068 00001fce 00000004 80b635e8 00000000
> 80b61f70 806de3c0 8046687c
>
> [34971.887678] 1f60: 200d0013 ffffffff
>
> [34971.891176] [<80013600>] (__irq_svc) from [<8046687c>]
> (cpuidle_enter_state+0x128/0x25c)
>
> [34971.899276] [<8046687c>] (cpuidle_enter_state) from [<8005917c>]
> (cpu_startup_entry+0x18c/0x270)
>
> [34971.908073] [<8005917c>] (cpu_startup_entry) from [<80a27c14>]
> (start_kernel+0x344/0x350)
>
> [34971.916253] CPU3: stopping
>
> [34971.918971] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G      D
> 4.4.0-rc5 #1
>
> [34971.926370] Hardware name: Freescale i.MX6 Quad/DualLite (Device T=
ree)
>
> [34971.932913] [<80016be4>] (unwind_backtrace) from [<80012b68>]
> (show_stack+0x10/0x14)
>
> [34971.940664] [<80012b68>] (show_stack) from [<802527f8>]
> (dump_stack+0x84/0xc4)
>
> [34971.947894] [<802527f8>] (dump_stack) from [<80015aa8>]
> (handle_IPI+0x1ac/0x1c0)
>
> [34971.955296] [<80015aa8>] (handle_IPI) from [<80009468>]
> (gic_handle_irq+0x84/0x88)
>
> [34971.962872] [<80009468>] (gic_handle_irq) from [<80013600>]
> (__irq_svc+0x40/0x74)
>
> [34971.970357] Exception stack(0xa80a5f58 to 0xa80a5fa0)
>
> [34971.975411] 5f40:
>    00000003 80930e14
>
> [34971.983594] 5f60: 00000001 2abcb000 00000000 ab729528 916661c0
> 00001fce 8da46492 00001fce
>
> [34971.991776] 5f80: 00000000 80b635e8 0000001b a80a5fa8 80058ec4
> 8046687c 200f0013 ffffffff
>
> [34971.999961] [<80013600>] (__irq_svc) from [<8046687c..
> [7:06:39 AM] Matti Pakarinen (Nextfour): [34971.999961] [<80013600>]
> (__irq_svc) from [<8046687c>] (cpuidle_enter_state+0x128/0x25c)
>
> [34972.008060] [<8046687c>] (cpuidle_enter_state) from [<8005917c>]
> (cpu_startup_entry+0x18c/0x270)
>
> [34972.016852] [<8005917c>] (cpu_startup_entry) from [<1000950c>]
> (0x1000950c)
>
> [34972.023820] Rebooting in 1 seconds..
>
>
> Thanks,
> --Mika
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
