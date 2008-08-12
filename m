From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: latest -git: kernel hangs when pulling the plug on 8139too
Date: Tue, 12 Aug 2008 22:46:21 +0200
Message-ID: <19f34abd0808121346w60f37ac0mf8e4ed20549af0e1@mail.gmail.com>
References: <19f34abd0808110949n5d7d363es66325b87a8fb0fd1@mail.gmail.com>
	 <20080811192739.GB5791@martell.zuzino.mipt.ru>
	 <19f34abd0808121020l4a0552a0v3d48b181d980d600@mail.gmail.com>
	 <19f34abd0808121202p6a59917ey561ac48012fb92ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:49875 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbYHLUqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 16:46:22 -0400
Received: by gxk9 with SMTP id 9so367778gxk.13
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 13:46:21 -0700 (PDT)
In-Reply-To: <19f34abd0808121202p6a59917ey561ac48012fb92ca@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 9:02 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> On Tue, Aug 12, 2008 at 7:20 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
>> ...but after pulling the cable and seeing the keyboard blink for five
>> seconds, the CPU resets without running the new kernel (i.e. it
>> reboots and I see the BIOS messages, etc.).
>>
>> Maybe I did something wrong? (Though I don't think so.)
>>
>> I will try to replace some printk()s to early_printk() (allows me to
>> maybe capture some messages on ttyS0 without trying to send anything
>> over netconsole).
>
> It turns out that we're not getting as far as the "panic:" line in panic().

Actually, I just forgot earlyprintk=...,keep.

Now I modified the printk() to use early_printk() if oops_in_progress is set.

This does actually give some result, but again the text is garbled,
this time for real, and I don't understand why.

But this is what I get on the serial console:

<0>BUG: NMI Watchdog detected LOCKUP on CPU1, ip c010ae8c, registers:
Pid: 0, comm: swapper Not tainted (2.6.27-rc2-00325-g796aade-dirty #3)
EIP: 0060:[<c010ae8c>] EFLAGS: 00000246 CPU: 1
EIP is at mwait_idle+0x3c/0x50
EAX: 00000000 EBX: f7894008 ECX: 00000000 EDX: 00000000
ESI: 00000001 EDI: c081ec00 EBP: f7895f7c ESP: f7895f78
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
<0>Process swapper (pid: 0, ti=f7894000 task=f7898000 task.ti=f7894000)
<0>Stack: c1fb1c00 f7895f94 c010285c c07d0020 c1f63020 00000001
00000000 f7895fb4
<0>       c058b859 00000000 00000000 00000000 00000000 01020800
00000000 00000000
<0>       00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000
<0>Call Trace:
<0> [<c010285c>] ? cpu_idle+0x6c/0x120
<0> [<c058b859>] ? start_secondary+0x169/0x1d0
<0> =======================
<0>Code: 08 75 2b 31 c9 89 d8 89 ca 0f 01 c8 0f ae f0 66 90 89 e0 25
00 e0 ff ff f6 40 08 08 75 10 e8 dc db 04 00 31 c9 89 c8 fb
0f 01 c9 <5b> 5d c3 e8 cc db 04 00 fb 0f 1f 84 00 00 00 00 00 90 eb ec 55
<0>KUG: N panatchdnot stected: AieUP kilCPU0,intec0upt 1andlegis
<4>---
Pid: --[ cmm: sre ]-r Not----nted<42.6.2INGc2-00/uio/796aaedesirty #ega
dnP: 0t-wo[<c02/lin8>] .6/keS: 0/smp.96 CPUsmp_calP isnction_ay_ts0x1398/0xb0()
AP: : 0,0006 : swaf796bNot taX: c0 2.6.2 EDc2-0001000796aSI: 03rty aa
ED[<c000000f>] Barn_o775cow ESP:0x4f70x80
 [<c0007b a>] ?0__pri: 00ymbGS+0x000 S4: 0 [<c0<3610ocess swaintk+0pid: 0x ti=
07740135d8sk= 06vpre0 t+0x2di=c077
00<c010>Sta>k: 0n0000e0 che75ca4ck+08a0b9xc077
cdc c12998d>] ? 1fb4ntk+05aeb0x3e0
 [c
150>  >]   p0775ccfunc15623bask+00001/0x1d8ab0[<c0018060b25d8sb0
f796s_cpuf796b0x50
<0>  58b8 000 00s6 rt_75cfndar5916b69/00000
0 000010ae 0>] b 55 f6s_acti f796b/0x2
 [Call 5d8de:
<0> [<ck+0x2b9>] ?0__de<c010x9/5>] ?
prin[<c0ace_a9>] ? +0x4_spin_
 [<0xb9/859>]
 0tart_0156ndb>] 0xtrac0x1d0dirq<c01f+0x0>] 10sto0> [<s_cpu6b6>/0x5_sp
[<cock_12qs] e+p_call_function[<c035bx60>] [<r010a39_star
_xmit_id65/0x1c/0x50> [<<c011255>>]  atl8139_p_set_xmitp+0x5/0x130
 [<c[<c04cc>] >  wanttpoll+0x3d_skb00x1[<c011a032>]>pani04cx62/0] ?
t[<c01sendc>] +0mwab/0xdle+0x0> [<50
c7<c0138aw2>] do_exix8c/0e2/0x<80 [ [<c05883>]>]
__shll_cogiolers+0vers+0x30/0x6<c020> [4>] 3 do_u]
la_cascreensole4/0x1ers+ [<c/
0x9dd9<0>  <c0_35a25xb9/ xf0
s[<c01sole_>] + xc5/0_idl
<0> /0x00
f0b>]10avpc>] k 0x1ib/0x3e+0x30> [<c
5 [<c01] e0_>] n_e_nmik_irf/0xfore+[<c010x70
]0> mwc0146dle+0 ? /0x50
_woc011x31/0] 0mi<0> [hdo1461e5+0x? 5/0ue_wo
 [<c45/0217>]<do_n<c01x97/0>] ? q [<e_dela03>]wnmi_stack_c0
rect [<c050x2b
>] ? 0spin_b>] c _iratestorl_ti43/0x36b/0x> [<c [<c0d1>]8c>s hemwae_delaeed_3c/0+0x1
/0x20
028> [<ccp3615le+ x6prix1200
 [<0x20
8<0> [scart9736>ndarmiix169ck_me0ia+===96/0==e0=
<0> [<====
27b>---[_end tlock+03bf506b02770> [ ]035
7<4>- ? --l_ch--[ cedia+re ]-0x30----> [<c035a0RNING?
atl8139/arkirrups/s292a/0x4dno
<it-wor01716linux? .6/dle_Il/smpent+06 smp_70ll_f> [<con_sinb>] 0 10a/le_f0()
iiirq+, com0xe0
<0>r Tai107128G       IR 2.648/0xc2-0<0> [g7968a604dirt
#3ce_hac0135s_of] thunkon_s/0x18
h+0> [<cx804a c>] ?6c14a>]_in__rrupt_sy28/0x0x2a/0> [<
0150013610? ] ? vpriall_ti3e+00x3e/0x7d<c013> [<c] 0av8c>] k+mwai/0x3ee+
 [c/0x500e5>> [<nat0285sched clo_k+0x+0x6c110120[
c0> ef9a>6bsmp>] llrfunctnit_sing/0x701
a0> ===
==<c01======= ? =top_thiode: +0x09 x50
 f0 815f0c2b  d pc all_d e8 7on_mab8 01 2d/00 50
8 <a 56 e6 >] ?9st0 25his_cp ff ff f50
 08c05875 17] ? s4 0c_secon <5f> xd c3 e1d00
4d 30 00 a0 a9 29 rd e8activc ff f0x20 8 [<c000
<>] ? vprintnic 2d/0t syncing:01051f kil? ng nt_trrupt
hdreser!x4</0x5----[<c05-[ c9>] ?rstart----onda--+0<4>9/0xING:
a[<c011/arkim desto29/vis_cdno/x0/0xorkin[<c01ux-2.6]
ern_callp.c:29ion+0_30/0_fun
tion010ae8cx13e 0x1it_id
e+0: 0,0x50
 [<c0per 5e>]tnatiG   mp_seW 2.top+0x12-00705-g7<c010e-di>] ?#mwa
[<cdle+53f>]0war
_ [<clowp432>]xpan0x80
2[<c016
4a<c01 ae8cint_ ymbol_idla/0x40/0 [<c
135d8138a02>] intexit2d/0x2/0x8 [<c0[<c010>] c>] ristk+0regisx3e0
0 [<c0x230
e>] cmp_caa4>] n tiounblank_scre/0x1x24/ [<c0
80<c010? d9>p_this_cpmi+0x/0x5xf0
[<c05010a2>] ] ? st_it_id0x62x3c70
0
 [<c022c>8c>]d? ay_tt_idlec/03b/0x [<c0[<c08d>] f>] rie_nmi+2d/0x0xf0
 [<c0010ae5>]    rintt_iale+0x3ress50
45[<c01
 05>05nmi_2>] ? og_t_initx1d5//0x70
 [<c0116217>] dostoi+0x97_cpu+0
0/0xc059 [<c015f120stasm_corre_funxti/0x2b3
/0xc0
007c028a 18>] e wally_tsc+0x36/0xb8d
 [ [<c0815e>c>nat ve_st_idln+0x3op+050
/0x<c010[<cc28 218>idled0x6c/tsc+0
8/0c058b [<c] 3543t_sepondc+0x62169120
 [< ===a218>====delay_t====x
<4>--8
 endc0138e 33b 576exit+932f2/0x-80
0>Reb01054g in 3  sec_regi.ters+0x7c/0x230
 [<c02ecfa4>] ? do_unblank_screen+0x24/0x130
 [<c0105dd9>] ? die_nmi+0xb9/0xf0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0105e0f>] die_nmi+0xef/0xf0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0119b05>] nmi_watchdog_tick+0x1d5/0x1e0
 [<c0106217>] do_nmi+0x97/0x2d0
 [<c0591f03>] nmi_stack_correct+0x26/0x2b
 [<c028007b>] ? as_remove_queued_request+0x9b/0xb0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c028a0b9>] __delay+0x9/0x10
 [<c0299579>] _raw_spin_lock+0xb9/0x140
 [<c015623b>] ? trace_hardirqs_off+0xb/0x10
 [<c05916b6>] _spin_lock_irqsave+0x76/0x90
 [<c035b255>] ? rtl8139_start_xmit+0x65/0x130
 [<c035b255>] rtl8139_start_xmit+0x65/0x130
 [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
 [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
 [<c037c70c>] write_msg+0x8c/0xc0
 [<c0135883>] __call_console_drivers+0x53/0x60
 [<c01358db>] _call_console_drivers+0x4b/0x90
 [<c0135a25>] release_console_sem+0xc5/0x1f0
 [<c0135f0b>] vprintk+0x1ab/0x3e0
 [<c0591acc>] ? _spin_unlock_irqrestore+0x6c/0x70
 [<c01460e1>] ? __queue_work+0x31/0x40
 [<c01461e5>] ? queue_work+0x45/0x50
 [<c014629f>] ? queue_delayed_work+0xf/0x30
 [<c0591aa3>] ? _spin_unlock_irqrestore+0x43/0x70
 [<c01462d1>] ? schedule_delayed_work+0x11/0x20
 [<c013615b>] printk+0x1b/0x20
 [<c0349736>] mii_check_media+0x196/0x1e0
 [<c059127b>] ? _spin_lock+0x5b/0x70
 [<c03597f4>] rtl_check_media+0x24/0x30
 [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0
 [<c01716d8>] handle_IRQ_event+0x28/0x70
 [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
 [<c0107128>] do_IRQ+0x48/0xa0
 [<c028a604>] ? trace_hardirqs_off_thunk+0xc/0x18
 [<c0104a5c>] common_interrupt+0x28/0x30
 [<c015007b>] ? update_wall_time+0x36b/0x7d0
 [<c010ae8c>] ? mwait_idle+0x3c/0x50
 [<c010285c>] cpu_idle+0x6c/0x120
 [<c056bb32>] rest_init+0x62/0x70
 =======================
<4>---[ end trace 33bf576b6277932f ]---
<4>------------[ cut here ]------------
<4>WARNING: at /uio/arkimedes/s29/vegardno/git-working/linux-2.6/kernel/smp.c:216
smp_call_function_single+0x10a/0x110()
Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc2-00325-g796aade-dirty #3
 [<c013553f>] warn_on_slowpath+0x4f/0x80
 [<c016014a>] ? __print_symbol+0x2a/0x40
 [<c0135d8d>] ? vprintk+0x2d/0x3e0
 [<c015ef9a>] smp_call_function_single+0x10a/0x110
 [<c0118060>] ? stop_this_cpu+0x0/0x50
 [<c015f0cd>] smp_call_function_mask+0x12d/0x150
 [<c0118060>] ? stop_this_cpu+0x0/0x50
 [<c056bb32>] ? rest_init+0x62/0x70
 [<c028a22c>] ? delay_tsc+0xac/0xb8
 [<c0135d8d>] ? vprintk+0x2d/0x3e0
 [<c01051f5>] ? print_trace_address+0x45/0x50
 [<c056bb32>] ? rest_init+0x62/0x70
 [<c0118060>] ? stop_this_cpu+0x0/0x50
 [<c015f120>] smp_call_function+0x30/0x60
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c011815e>] native_smp_send_stop+0x1e/0x70
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0135432>] panic+0x62/0x120
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0138a02>] do_exit+0x7e2/0x880
 [<c01054bc>] ? show_registers+0x7c/0x230
 [<c02ecfa4>] ? do_unblank_screen+0x24/0x130
 [<c0105dd9>] ? die_nmi+0xb9/0xf0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0105e0f>] die_nmi+0xef/0xf0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c0119b05>] nmi_watchdog_tick+0x1d5/0x1e0
 [<c0106217>] do_nmi+0x97/0x2d0
 [<c0591f03>] nmi_stack_correct+0x26/0x2b
 [<c028007b>] ? as_remove_queued_request+0x9b/0xb0
 [<c028a218>] ? delay_tsc+0x98/0xb8
 [<c028a0b9>] __delay+0x9/0x10
 [<c0299579>] _raw_spin_lock+0xb9/0x140
 [<c015623b>] ? trace_hardirqs_off+0xb/0x10
 [<c05916b6>] _spin_lock_irqsave+0x76/0x90
 [<c035b255>] ? rtl8139_start_xmit+0x65/0x130
 [<c035b255>] rtl8139_start_xmit+0x65/0x130
 [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
 [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
 [<c037c70c>] write_msg+0x8c/0xc0
 [<c0135883>] __call_console_drivers+0x53/0x60
 [<c01358db>] _call_console_drivers+0x4b/0x90
 [<c0135a25>] release_console_sem+0xc5/0x1f0
 [<c0135f0b>] vprintk+0x1ab/0x3e0
 [<c0591acc>] ? _spin_unlock_irqrestore+0x6c/0x70
 [<c01460e1>] ? __queue_work+0x31/0x40
 [<c01461e5>] ? queue_work+0x45/0x50
 [<c014629f>] ? queue_delayed_work+0xf/0x30
 [<c0591aa3>] ? _spin_unlock_irqrestore+0x43/0x70
 [<c01462d1>] ? schedule_delayed_work+0x11/0x20
 [<c013615b>] printk+0x1b/0x20
 [<c0349736>] mii_check_media+0x196/0x1e0
 [<c059127b>] ? _spin_lock+0x5b/0x70
 [<c03597f4>] rtl_check_media+0x24/0x30
 [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0
 [<c01716d8>] handle_IRQ_event+0x28/0x70
 [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
 [<c0107128>] do_IRQ+0x48/0xa0
 [<c028a604>] ? trace_hardirqs_off_thunk+0xc/0x18
 [<c0104a5c>] common_interrupt+0x28/0x30
 [<c015007b>] ? update_wall_time+0x36b/0x7d0
 [<c010ae8c>] ? mwait_idle+0x3c/0x50
 [<c010285c>] cpu_idle+0x6c/0x120
 [<c056bb32>] rest_init+0x62/0x70
 =======================
<4>---[ end trace 33bf576b6277932f ]---

...this seems to contain at least a little bit of useful information.

Looks to me like it's quite simply a recursive printk. I don't
understand why the printk code doesn't catch this, though.

Any ideas?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
