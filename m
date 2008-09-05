From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Fri, 5 Sep 2008 19:03:38 +0300
Message-ID: <200809051903.41103.rdenis@simphalempin.com>
References: <bug-11469-10286@http.bugzilla.kernel.org/> <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080905114146.GA29408@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47307 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbYIEQDp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 12:03:45 -0400
In-Reply-To: <20080905114146.GA29408@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 5 septembre 2008 14:41:50 Evgeniy Polyakov, vous avez =E9cr=
it=A0:
> Hi.
>
> On Sun, Aug 31, 2008 at 11:13:04AM -0700, Andrew Morton=20
(akpm@linux-foundation.org) wrote:
> > > When an IFF_TUN (/dev/net/tun) device has more than 1023 IPv6
> > > neighbors, a process context crash occurs. Backtrace follows:
>
> Does this problem still exist?

Yes. With 2.6.27-rc5-b380b0d4f7dffcc235c0facefa537d4655619101, I get th=
is:

tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
tun0: Disabled Privacy Extensions
BUG: unable to handle kernel NULL pointer dereference at 0000001d
IP: [<f8b205a0>] :ipv6:ip6_dst_lookup_tail+0x9e/0x166
*pde =3D 00000000
Oops: 0000 [#1] SMP
Modules linked in: tun fuse nf_conntrack_ftp nf_conntrack_ipv6=20
nf_conntrack_ipv4 nf_conntrack ipv6 snd_intel8x0 snd_ac97_codec ac97_bu=
s=20
snd_pcm_oss snd_mixer_oss snd_pcm snd_se
q_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer=20
snd_seq_device snd soundcore intel_agp agpgart snd_page_alloc psmouse=20
iTCO_wdt evdev button parport_pc proce
ssor parport pcspkr dm_mirror dm_log dm_snapshot sg sr_mod cdrom e100 e=
hci_hcd=20
uhci_hcd usbcore unix

Pid: 2313, comm: tunload Not tainted (2.6.27-rc5-00132-gb380b0d #13)
EIP: 0060:[<f8b205a0>] EFLAGS: 00010246 CPU: 0
EIP is at ip6_dst_lookup_tail+0x9e/0x166 [ipv6]
EAX: 00000000 EBX: f7d7fd38 ECX: f678e800 EDX: f7cb9600
ESI: f67aa400 EDI: 00000000 EBP: f7d7fcb4 ESP: f7d7fc5c
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process tunload (pid: 2313, ti=3Df7d7e000 task=3Df66a3b60 task.ti=3Df7d=
7e000)
Stack: 00000000 f7d7fd54 f7d7fda8 f67aa400 f7d7fc7c f8b1f8e8 00000000 f=
6528e40
       f7d7fcbc f8b211b2 f7d7fdb8 f67aa400 f7cb8900 f67aa624 00000000 0=
0000246
       f7d7fca4 c03124da f7d7fcbc 00000000 f7d7fed0 00000000 f7d7fcbc f=
8b207bd
Call Trace:
 [<f8b1f8e8>] ? ip6_cork_release+0x2e/0x52 [ipv6]
 [<f8b211b2>] ? ip6_push_pending_frames+0x1c9/0x3d9 [ipv6]
 [<c03124da>] ? _spin_unlock_bh+0xd/0xf
 [<f8b207bd>] ? ip6_dst_lookup+0xe/0x10 [ipv6]
 [<f8b353fa>] ? rawv6_sendmsg+0x25d/0xc08 [ipv6]
 [<c01401e6>] ? clockevents_program_event+0x92/0x119
 [<c02eed00>] ? inet_sendmsg+0x2e/0x50
 [<c02a7bad>] ? sock_sendmsg+0xcc/0xf0
 [<c011d3a9>] ? find_busiest_group+0x160/0x7a0
 [<c01372a5>] ? autoremove_wake_function+0x0/0x3a
 [<c02ad2ba>] ? __kfree_skb+0x31/0x76
 [<c02ad2ba>] ? __kfree_skb+0x31/0x76
 [<c0137449>] ? remove_wait_queue+0x30/0x34
 [<c021ba5f>] ? copy_from_user+0x2a/0x114
 [<c02a7e85>] ? sys_sendto+0xa5/0xc5
 [<c01401e6>] ? clockevents_program_event+0x92/0x119
 [<c01372a5>] ? autoremove_wake_function+0x0/0x3a
 [<c02a8d31>] ? sys_socketcall+0x176/0x295
 [<c0103061>] ? sysenter_do_call+0x12/0x25
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 22 83 ff 9b 74 37 8b 55 b0 8b 02 e8 24 63 79 c7 8b 4d b0 c7 01 00=
 00 00=20
00 89 f8 83 c4 4c 5b 5e 5f 5d c3 8b 45 b0 8b 10 8b 42 2c <f6> 40 1d de =
74 23=20
31 ff 89 f8 83 c4 4c 5b 5e 5f 5d c3 64 a1 04
EIP: [<f8b205a0>] ip6_dst_lookup_tail+0x9e/0x166 [ipv6] SS:ESP 0068:f7d=
7fc5c
---[ end trace fd93373c6fb8880e ]---

> > > Pid: 9950, comm: tunload Tainted: G      D   (2.6.26.3 #8)
>
> By whom it was tainted?

Its own self. I just failed to copy the very first crash trace.

Regards,

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
