From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: G5 with tg3 ethernet stops when rsyncing large amounts of data
Date: Tue, 23 Sep 2008 17:04:36 +0200
Message-ID: <1222182276.18015.26.camel@johannes.berg>
References: <1222181098.18015.23.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wjblT1vQc17So9GawzfD"
Cc: netdev <netdev@vger.kernel.org>
To: Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41382 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYIWPFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 11:05:19 -0400
In-Reply-To: <1222181098.18015.23.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wjblT1vQc17So9GawzfD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-09-23 at 16:45 +0200, Johannes Berg wrote:
> I've been trying to push a few GB of data from my powerbook to my quad
> G5 with rsync, but after transferring for a bit the machine stops
> entirely. It doesn't even reply to ping, so this must be happening in an
> interrupt.
>=20
> The only information I have so far is a picture I took of the console
> when this happened again:
> http://johannes.sipsolutions.net/files/dsc_2275.jpg
>=20
> Unfortunately, there isn't even a backtrace for some reason.

This time I got the trace below (system didn't hang)...

I'd think faulty memory if it weren't for the fact that I never see
problems when I do random things that don't involve networking.

[  493.257620] ------------[ cut here ]------------
[  493.270431] kernel BUG at kernel/seccomp.c:50!
[  493.283978] Oops: Exception in kernel mode, sig: 5 [#1]
[  493.283984] PREEMPT SMP NR_CPUS=3D4 PowerMac
[  493.283997] Modules linked in: binfmt_misc ipv6 dm_crypt dm_snapshot dm_=
mirror dm_log dm_mod fuse snd_aoa_codec_onyx snd_aoa_fabric_layout snd_aoa =
snd_aoa_i2sbus snd_aoa_soundbus snd_pcm_oss snd_mixer_oss firewire_ohci fir=
ewire_core snd_pcm crc_itu_t snd_page_alloc snd_timer snd rfkill ohci1394 m=
ac80211 ehci_hcd ohci_hcd soundcore ieee1394 usbcore cfg80211
[  493.284091] NIP: c0000000000bf98c LR: c0000000000bf93c CTR: 000000000000=
0000
[  493.284099] REGS: c0000001b0353a90 TRAP: 0700   Not tainted  (2.6.27-rc6=
-wl-01382-g0bea1f7-dirty)
[  493.284104] MSR: 9000000000029032 <EE,ME,IR,DR>  CR: 24224828  XER: 0000=
0000
[  493.284122] TASK =3D c0000001b0256d00[4894] 'rsync' THREAD: c0000001b035=
0000 CPU: 1
[  493.284129] GPR00: 0000000000000000 c0000001b0353d10 c0000000008b23e0 00=
00000000000001=20
[  493.284140] GPR04: 0000000000000000 c0000001b0256d00 c0000002006e9a30 c0=
000001b0256d00=20
[  493.284151] GPR08: c0000001b0350000 c0000001b0256d00 0000000001b90000 c0=
000000007e3ad8=20
[  493.284162] GPR12: 0000000024224824 c000000000943580 0000000010074390 00=
00000000000004=20
[  493.284173] GPR16: 00000000ff8753f8 0000000010080c18 0000000010073d5c 00=
000000ff875050=20
[  493.284184] GPR20: 0000000000000000 00000000ff875048 0000000010073d5c 00=
00000000000020=20
[  493.284195] GPR24: 00000001f7fe3238 0000000010080c18 0000000000000005 00=
000000ff875050=20
[  493.284205] GPR28: 0000000000000005 000000000000008e c000000000847ab8 c0=
000001b0353d10=20
[  493.284227] NIP [c0000000000bf98c] .__secure_computing+0x78/0xa8
[  493.284233] LR [c0000000000bf93c] .__secure_computing+0x28/0xa8
[  493.284238] Call Trace:
[  493.284245] [c0000001b0353d10] [c0000000000bf93c] .__secure_computing+0x=
28/0xa8 (unreliable)
[  493.284257] [c0000001b0353da0] [c000000000008b7c] .do_syscall_trace_ente=
r+0x40/0x12c
[  493.284266] [c0000001b0353e30] [c000000000007794] syscall_dotrace+0xc/0x=
38
[  493.284272] Instruction dump:
[  493.284280] 7809e7e3 4182000c 7d695b78 48000008 392b0014 80090000 7f80e8=
00 419e0028=20
[  493.284298] 84090004 2f800000 409effec 4800000c <0fe00000> 48000000 3860=
0009 4bf9f409=20
[  493.285036] BUG: using smp_processor_id() in preemptible [00000000] code=
: rsync/4894
[  493.285049] caller is .die+0x198/0x1e4
[  493.285053] Call Trace:
[  493.285061] [c0000001b0353500] [c0000000000108ec] .show_stack+0x84/0x190=
 (unreliable)
[  493.285074] [c0000001b03535b0] [c000000000463c60] .dump_stack+0x28/0x3c
[  493.285085] [c0000001b0353630] [c0000000002ac658] .debug_smp_processor_i=
d+0xe8/0x124
[  493.285094] [c0000001b03536d0] [c000000000023bc8] .die+0x198/0x1e4
[  493.285103] [c0000001b0353780] [c000000000023f5c] ._exception+0x98/0x1fc
[  493.285112] [c0000001b0353940] [c000000000024808] .program_check_excepti=
on+0x610/0x65c
[  493.285122] [c0000001b0353a20] [c000000000004a84] program_check_common+0=
x104/0x180
[  493.285135] --- Exception: 700 at .__secure_computing+0x78/0xa8
[  493.285138]     LR =3D .__secure_computing+0x28/0xa8
[  493.285146] [c0000001b0353da0] [c000000000008b7c] .do_syscall_trace_ente=
r+0x40/0x12c
[  493.285155] [c0000001b0353e30] [c000000000007794] syscall_dotrace+0xc/0x=
38
[  493.285165] ---[ end trace 488bc840169e13ad ]---


--=-wjblT1vQc17So9GawzfD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI2QWAAAoJEKVg1VMiehFY3tsQAMPVC67I8GjMAX76uPCGrPMZ
rr9QT/mgVYModONq0AcyNpuhsJfiBtNTqvAKTmFvBBep4K0+IVjNPmCtyVVH2cAQ
8Sm4UhJb8hWaVIfN9MP9/KxFesYNPWiiwUBFQoVl8jjoHTimHHK3SDFm07VTYfRY
K22dbDW01eD0O7KhjD0LaOd1/3RNZFV6OxmjnOZx9kSvUrpkG9xV3J7kO0UXVew4
wsKfGO2uD/dTNgb4F4EXkQ1Znf+F7f5jjC5pgBiwmQOtCdM6IAMB7CdYai3VtCdW
ip4UyjAZte2ekZBR69Bu1rojQZ3iKaaFA1P6Q5QhZPSK8DdtgcyDBiI9DmJXjqCw
m0s6ke4qpKi7GMHcJ3gaSXhCHdTbsaxOMYMERWmFwIu9WSrHWiAQjzEP0vkPCJzZ
9L7br62fr0HByRYRVENUsuh0UHCCIzkWpNX+0JJRDN7mZZzmL8/Tp+jXHDG9BhB3
z5nvvQviSUhBRCRyFtFiV6y1d/ki4C61aaThv2marppY1eblPZDx//2IuIo/xepn
gsCPJacPN84LvNnyMD9v7ujZY7P4M5jBYtaHO+7c+iK+L7GsRgu7MuqGyBqNJ4vJ
qLN+Bpz2ea1oKH5GDoVf8puhAvb32B/mWcHTj6FQADzZsSiaLP+utX+cSdd4qBS7
HT4Ze9c9x84Y41cy2hP4
=qhAf
-----END PGP SIGNATURE-----

--=-wjblT1vQc17So9GawzfD--

