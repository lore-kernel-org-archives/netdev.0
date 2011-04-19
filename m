From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 19 Apr 2011 04:51:06 +0200
Message-ID: <1303181466.4152.39.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59811 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab1DSCvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 22:51:14 -0400
Received: by wya21 with SMTP id 21so4450600wya.19
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 19:51:12 -0700 (PDT)
In-Reply-To: <20110418153852.153d3ed3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 avril 2011 =C3=A0 15:38 -0700, Andrew Morton a =C3=A9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Sun, 17 Apr 2011 19:29:39 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D33502
> >=20
> >            Summary: Caught 64-bit read from uninitialized memory in
> >                     __alloc_skb
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.39-rc3
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: casteyde.christian@free.fr
> >         Regression: Yes
> >=20
> >=20
> > Acer Aspire 1511LMi
> > Athlon 64 3GHz in 64bits mode
> > Slackware 64 13.1
> >=20
> > Since 2.6.39-rc3 with kmemcheck enabled, I get the following warnin=
g:
> > ...
> > pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff: e=
xcluding
> > 0xc0000-0xfffff
> > pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60fffff=
f: excluding
> > 0x60000000-0x
> > 60ffffff
> > pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0fffff=
f: excluding
> > 0xa0000000-0x
> > a0ffffff
> > udev: renamed network interface wlan0 to eth1
> > WARNING: kmemcheck: Caught 64-bit read from uninitialized memory
> > (ffff88001b0bb800)
> > 00b00b1b0088ffff0000000000000000cafe1dea20009b0000299a3100000000
> >  u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
> >  ^
> >=20
> > Pid: 1511, comm: udevd Not tainted 2.6.39-rc3 #1 Acer,Inc. Aspire 1=
510  /Aspire
> > 1510
> > RIP: 0010:[<ffffffff810c2f0c>]  [<ffffffff810c2f0c>]
> > __kmalloc_track_caller+0xbc/0x1d0
> > RSP: 0018:ffff88001d3a7a18  EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: 0000000000000010 RCX: 000000000000284f
> > RDX: 000000000000284e RSI: ffff88001fe5b160 RDI: ffffffff8177e39a
> > RBP: ffff88001d3a7a48 R08: 0000000000000000 R09: ffff88001b931100
> > R10: 0000000000000000 R11: 0000000000000003 R12: ffff88001b0bb800
> > R13: ffff88001f803840 R14: 00000000000004d0 R15: ffffffff814769c6
> > FS:  00007f6ee81f1700(0000) GS:ffffffff81a1b000(0000) knlGS:0000000=
000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: ffff88001d0b3938 CR3: 000000001d38b000 CR4: 00000000000006f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> >  [<ffffffff8147ccf2>] __alloc_skb+0x72/0x190
> >  [<ffffffff814769c6>] sock_alloc_send_pskb+0x236/0x3a0
> >  [<ffffffff81476b40>] sock_alloc_send_skb+0x10/0x20
> >  [<ffffffff81523c18>] unix_dgram_sendmsg+0x298/0x770
> >  [<ffffffff814715f3>] sock_sendmsg+0xe3/0x110
> >  [<ffffffff81472603>] sys_sendmsg+0x243/0x3c0
> >  [<ffffffff815e7238>] system_call_fastpath+0x16/0x1b
> >  [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> hum.  I wonder if kmemcheck is disliking prefetchw()?

Nope, prefetchw() is OK versus kmemcheck.

This is in __kmalloc_track_caller(), not in networking stuff.

CC Christoph Lameter

I guess this_cpu_cmpxchg16b() is the offender.

A disassembly of __kmalloc_track_caller() would help, but I feel its th=
e
read of s->cpu_slab->freelist

It seems to be at address=20
0xffff88001b0bb800 and contains 0xffff88001b0bb000 but kmemcheck thinks
its not initialized.

Its located in percpu zone, maybe kmemcheck has a problem with it ?

alloc_kmem_cache_cpus() does a call to __alloc_percpu(), so this must
have been zeroed at the very beginning of kmem_cache life.


Hmm, looking at mm/slub.c, I wonder what prevents "object" from pointin=
g
to a now freed and unreachable zone of memory. (Say we are interrupted,
object given to interrupt handler and this one wants to change page bit=
s
to trap access)



