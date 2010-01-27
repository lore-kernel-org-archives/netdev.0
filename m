From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: 2.6.33-rc5: (e1000): transmit queue 0 timed out
Date: Tue, 26 Jan 2010 17:12:16 -0800
Message-ID: <4807377b1001261712m9d161b6s700cc76b2f2edaf4@mail.gmail.com>
References: <a4423d671001230737i3b3c7da1q6cd4ce615888b36e@mail.gmail.com>
	 <201001232052.32230.rjw@sisk.pl>
	 <a4423d671001231204w3e742938u5f1021abb7a5e07c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Alexander Beregalov <a.beregalov@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:39020 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab0A0BMb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 20:12:31 -0500
Received: by yxe17 with SMTP id 17so4194105yxe.33
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 17:12:30 -0800 (PST)
In-Reply-To: <a4423d671001231204w3e742938u5f1021abb7a5e07c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also just noticed something else.

On Sat, Jan 23, 2010 at 12:04 PM, Alexander Beregalov
<a.beregalov@gmail.com> wrote:
>>> Pid: 5, comm: events/0 Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0=
2.6.33-rc5 #1
>>> NF7-S/NF7,NF7-V (nVidia-nForce2)/
>>> EIP: 0060:[<c1071c51>] EFLAGS: 00010282 CPU: 0
>>> EIP is at put_page+0x11/0x120
>>> EAX: 2e8ca4f3 EBX: 2e8ca4f3 ECX: 00000000 EDX: ee960640
>>> ESI: f6482620 EDI: 000016b0 EBP: f7065ea8 ESP: f7065e98
>>> =C2=A0DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>>> Process events/0 (pid: 5, ti=3Df7064000 task=3Df70553c0 task.ti=3Df=
7064000)
>>> Stack:
>>> =C2=A000000206 00000001 f6482620 000016b0 f7065eb8 c12d3100 f648262=
0 f71d9f50
>>> <0> f7065ec4 c12d2e32 f80376b0 f7065ecc c12d2ec5 f7065f00 c1276970 =
cccccccd
>>> <0> f7065f00 f711fafc f711fafc f711faa0 00000000 f702b440 000000f2 =
f702b440
>>> Call Trace:
>>> =C2=A0[<c12d3100>] ? skb_release_data+0x90/0xa0
>>> =C2=A0[<c12d2e32>] ? __kfree_skb+0x12/0x90
>>> =C2=A0[<c12d2ec5>] ? consume_skb+0x15/0x30
>>> =C2=A0[<c1276970>] ? e1000_clean_rx_ring+0x80/0x150
>>> =C2=A0[<c127c743>] ? e1000_down+0x1b3/0x1d0
>>> =C2=A0[<c127cf60>] ? e1000_reset_task+0x0/0x10
>>> =C2=A0[<c127cd3b>] ? e1000_reinit_locked+0x4b/0x70
>>> =C2=A0[<c127cf6d>] ? e1000_reset_task+0xd/0x10
>>> =C2=A0[<c103a9ea>] ? worker_thread+0x14a/0x230
>>> =C2=A0[<c103a989>] ? worker_thread+0xe9/0x230
>>> =C2=A0[<c103e160>] ? autoremove_wake_function+0x0/0x40
>>> =C2=A0[<c103a8a0>] ? worker_thread+0x0/0x230
>>> =C2=A0[<c103de6c>] ? kthread+0x6c/0x80
>>> =C2=A0[<c103de00>] ? kthread+0x0/0x80
>>> =C2=A0[<c100303a>] ? kernel_thread_helper+0x6/0x1c
> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1c5/0x1d0()
> Hardware name:
> NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out

There are at least two problems here, not sure if they are related yet.
The first is the WATCHDOG (the kernel will print this only once per
e1000e driver load), we don't know what is causing that right now,
maybe we can mock up some ftrace magic to dump the transmit
descriptors that are formed, or you can run the e1000_dump patch code.
 Let me know if you want me to generate a version of it for you.

> <..>
> BUG kmalloc-2048: Poison overwritten
> ---------------------------------------------------------------------=
--------
>
> INFO: 0xf4998022-0xf4998607. First byte 0x0 instead of 0x6b
> INFO: Allocated in __netdev_alloc_skb+0x1e/0x40 age=3D372 cpu=3D0 pid=
=3D1724
> INFO: Freed in skb_release_data+0x68/0xa0 age=3D292 cpu=3D0 pid=3D5
> INFO: Slab 0xc2283300 objects=3D15 used=3D0 fp=3D0xf499b950 flags=3D0=
x40004082
> INFO: Object 0xf4998000 @offset=3D0 fp=3D0xf499d1e0
>
> =C2=A0Object 0xf4998000: =C2=A06b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b
> kkkkkkkkkkkkkkkk
> =C2=A0Object 0xf4998010: =C2=A06b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b
> kkkkkkkkkkkkkkkk
> =C2=A0Object 0xf4998020: =C2=A06b 6b 00 07 e9 09 d4 79 01 14 2b 09 0b=
 28 08 00
> kk..=D0=98.=D1=82y..+..(..
> =C2=A0Object 0xf4998030: =C2=A045 20 05 d4 7d 09 40 00 75 06 3c e5 d5=
 b6 b0 b4
> E..=D1=82}.@.u.<=D0=95=D1=83=E2=95=A4=E2=95=9F=E2=95=A2
> =C2=A0Object 0xf4998040: =C2=A0c1 a8 01 02 23 28 af a3 57 1f 82 b2 c7=
 a5 14 d5
> =D0=B0=E2=95=97..#(=E2=95=9E=D1=91W..=E2=95=A1=D0=B3=E2=95=94.=D1=83
> <..>

hey, thats an ethernet/ipv4 packet!  The memory above is typically
allocated at a 2kB boundary and then the hardware would start DMAing
at 000+22...  how long was that packet corrupting data in memory (how
many bytes)?

00 07 e9 09 d4 79
dest mac
01 14 2b 09 0b 28
src mac address
08 00
ip header
45 20
header length 20 bytes, ip v4, DSCP =3D ECN capable
and on...

so this is the second issue, we've called kfree on a packet but
hardware still receives into it (probably that we didn't wait long
enough for receives to quit)

> =C2=A0Object 0xf49987d0: =C2=A06b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b
> kkkkkkkkkkkkkkkk
> =C2=A0Object 0xf49987e0: =C2=A06b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b
> kkkkkkkkkkkkkkkk
> =C2=A0Object 0xf49987f0: =C2=A06b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b a5
> kkkkkkkkkkkkkkk=E2=95=94
> =C2=A0Redzone 0xf4998800: =C2=A0bb bb bb bb =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =E2=95=A9=E2=95=A9=E2=95=A9=E2=95=A9
> =C2=A0Padding 0xf4998828: =C2=A05a 5a 5a 5a 5a 5a 5a 5a =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
ZZZZZZZZ
> Pid: 1719, comm: rtorrent Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=
=A02.6.33-rc5 #1
> Call Trace:
> =C2=A0[<c108d1af>] print_trailer+0xcf/0x120
> =C2=A0[<c108d844>] check_bytes_and_report+0xc4/0xf0
> =C2=A0[<c108da1f>] check_object+0x1af/0x200
> =C2=A0[<c108db4a>] __free_slab+0xda/0x100
> =C2=A0[<c108db8c>] discard_slab+0x1c/0x30
> =C2=A0[<c108f552>] __slab_free+0xd2/0x280
> =C2=A0[<c11d7156>] ? copy_to_user+0x36/0x130
> =C2=A0[<c108f9df>] kfree+0xdf/0x110
> =C2=A0[<c12d30d8>] ? skb_release_data+0x68/0xa0
> =C2=A0[<c12d30d8>] ? skb_release_data+0x68/0xa0
> =C2=A0[<c12d30d8>] skb_release_data+0x68/0xa0
> =C2=A0[<c12d2e32>] __kfree_skb+0x12/0x90
> =C2=A0[<c13006a0>] tcp_recvmsg+0x6c0/0x8d0
> =C2=A0[<c102f691>] ? local_bh_enable_ip+0x61/0xc0
> =C2=A0[<c1350b75>] ? _raw_spin_unlock_bh+0x25/0x30
> =C2=A0[<c10435e5>] ? T.324+0x15/0x1b0
> =C2=A0[<c12cdc73>] sock_common_recvmsg+0x43/0x60
> =C2=A0[<c12cbc87>] sock_recvmsg+0xb7/0xf0
> =C2=A0[<c10435e5>] ? T.324+0x15/0x1b0
> =C2=A0[<c12cc589>] sys_recvfrom+0x79/0xe0
> =C2=A0[<c104d66b>] ? trace_hardirqs_off+0xb/0x10
> =C2=A0[<c104398e>] ? cpu_clock+0x4e/0x60
> =C2=A0[<c104d6a7>] ? lock_release_holdtime+0x37/0x1b0
> =C2=A0[<c1052121>] ? lock_release_non_nested+0x301/0x340
> =C2=A0[<c104d6a7>] ? lock_release_holdtime+0x37/0x1b0
> =C2=A0[<c107bd0a>] ? might_fault+0x4a/0xa0
> =C2=A0[<c12cc626>] sys_recv+0x36/0x40
> =C2=A0[<c12cd74c>] sys_socketcall+0x1ac/0x270
> =C2=A0[<c11d68f4>] ? trace_hardirqs_on_thunk+0xc/0x10
> =C2=A0[<c1002b10>] sysenter_do_call+0x12/0x36
> FIX kmalloc-2048: Restoring 0xf4998022-0xf4998607=3D0x6b

I'll reply here with a patch for checking if the receive unit is still
not stopped, but I still don't know what is causing the NETDEV
WATCHDOG and we need some more debug information for that (from the
e1000_dump patch)

can you answer any of my other questions too?
