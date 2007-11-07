From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23.1-smp  kernel panic (network-related)
Date: Wed, 7 Nov 2007 12:23:19 -0800
Message-ID: <20071107122319.6b342763.akpm@linux-foundation.org>
References: <20071107175211.1a12c8c9@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marek Kierdelewicz <marek@koba.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55189 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753846AbXKGUX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 15:23:59 -0500
In-Reply-To: <20071107175211.1a12c8c9@catlap>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc netdev)

> On Wed, 7 Nov 2007 17:52:11 +0100 Marek Kierdelewicz <marek@koba.pl> =
wrote:
> Hi there,
>=20
> My company's (ISP) bussines model requires dynamic resizing of the
> client queues. It's achieved by regenerating shaping rules and loadin=
g
> then using batch mode of a tc binary. On production systems it's done
> once every 1 or 2 minutes. Unfortunately this causes smp kernels to
> panic. Non-smp kernels don't have such problems. Bug is around a long
> time. I first noticed it after migrating to shaping configs that use
> IFB, it might have been 2.6.18 "era".
>=20
> Test scenario:
>=20
> I've put together a test machine with configuration copied from
> production router. I'm feeding the machine with production traffic
> by means of port mirroring. Test machine has the same config as
> production one (including mac addresses), so it tries to route the
> incoming traffic.
>=20
> Tested kernels were 2.6.31.1 and 2.6.20.6 (config from 2.6.20.6 is in
> attachment). Both panicked if compiled with SMP support and work stab=
le
> otherwise. Problem occurs only with cyclic "shaping restarts". For th=
e
> test, reload operation using "tc -b ..." was executed in an infinite
> loop.=20
>=20
> Box's CPU usage was approximately 15%. Panics occur with few hours -
> one day intervals.
>=20
>=20
> Below I attach the panic message captured via serial console:
> ---------------------------------------------------------------------=
-
> printk: 63 messages suppressed.
> dst cache overflow
> SMP
> Modules linked in: ipt_LOG xt_hashlimit ipt_MASQUERADE ip_set_macipma=
p
> ip_set_ipmap xt_state w83627hf hwmon_vid eeprom ifb ipt_SET ipt_set
> ip_set ipip tunnel4 ip_gre e1000 i2c_i801 i2c_core CPU:    1 EIP:
> 0060:[<f255c08f>]    Not tainted VLI EFLAGS: 00010202   (2.6.23.1-smp
> #2) EIP is at 0xf255c08f
> eax: c196a000   ebx: 00000100   ecx: ef2f408c   edx: f3630000
> esi: f0332029   edi: f255c08c   ebp: 00000001   esp: f3631ea8
> ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> Process tc (pid: 27695, ti=3Df3630000 task=3Df26a9560 task.ti=3Df3630=
000)
> Stack: c01280ad f26a9560 00000001 f3631eb4 c0106f57 ef2f408c f0e8c08c
> 00000031 c0495308 0000000a c0124eb6 00000046 00000000 f7657740 f36300=
00
> c0124f4c c180f120 c0114e62 00000000 00000000 f7bfd224 f74ed95c c01047=
e0
> f7bfd224 Call Trace:
>  [<c01280ad>] run_timer_softirq+0xf5/0x154
>  [<c0106f57>] profile_pc+0x21/0x4a
>  [<c0124eb6>] __do_softirq+0x5d/0xc1
>  [<c0124f4c>] do_softirq+0x32/0x36
>  [<c0114e62>] smp_apic_timer_interrupt+0x74/0x80
>  [<c01047e0>] apic_timer_interrupt+0x28/0x30
>  [<c014c82e>] remove_vma+0x1c/0x36
>  [<c014c912>] exit_mmap+0xca/0xe1
>  [<c011eedc>] mmput+0x1d/0x75
>  [<c0123688>] do_exit+0x1be/0x68a
>  [<c0123bc0>] sys_exit_group+0x0/0xd
>  [<c0103d12>] sysenter_past_esp+0x5f/0x85
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Code: 00 52 41 f7 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =
00
> 00 00 00 00 00 00 fa 00 00 00 ea 05 00 00 7f 00 00 00 34 a5 96 <c1> 8=
c
> 00 fd f3 a5 2b 09 00 d1 d8 32 c0 00 c0 55 f2 00 a0 96 c1 EIP:
> [<f255c08f>] 0xf255c08f SS:ESP 0068:f3631ea8 Kernel panic - not
> syncing: Fatal exception in interrupt
> ---------------------------------------------------------------------=
-
>=20
>=20
> --=20
> Marek Kierdelewicz
> Kierownik Dzia=C5=82u System=C3=B3w Sieciowych, KoBa
> Manager of Network Systems Department, KoBa
> tel. (85) 7406466; fax. (85) 7406467
> e-mail: admin@koba.pl
>=20
