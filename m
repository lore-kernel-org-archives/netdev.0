From: Cosmin GIRADU <cosmin.giradu@rcs-rds.ro>
Subject: BCM5721 transmit queue 0 timed out
Date: Thu, 18 Jul 2013 11:47:25 +0300
Message-ID: <51E7AB9D.3010803@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DM9vPe9CPQo6fc4tRjjRQwXHT0iKqDVvp"
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:38688 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757776Ab3GRIzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 04:55:03 -0400
Received: from cnyk.rdsnet.ro (cnyk.rdsnet.ro [86.120.6.54])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailproxy.rcs-rds.ro (Postfix) with ESMTPSA id B3FF97B007
	for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 08:51:49 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DM9vPe9CPQo6fc4tRjjRQwXHT0iKqDVvp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I need some help with the following situation:

We keep getting random lockups on our BCM5721 cards (most of them are
LOMs, multiple machines, running multiple kernel versions between 3.4
and 3.10.1), when the traffic is high (above 300Mbit/s). The hardware is
dual port "Tigon3 [partno(BCM95721) rev 4201] (PCI Express)" with 5750
chip inside.
The lockups look like this:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x25a/0x270()
NETDEV WATCHDOG: eth2 (tg3): transmit queue 0 timed out
Modules linked in: ip_gre ip_tunnel gre loop processor thermal_sys
i2c_i801 lpc_ich coretemp button mfd_core
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.1.htb.104 #1
Hardware name: IBM IBM System x3250 -[43654BG]-/M31ip, BIOS IBM BIOS
Version 1.33-[G9E133AUS-1.33]- 08/28/2007
 ffffffff81781f16 ffff88003fd03d98 ffffffff8152f6eb ffff88003fd03dd8
 ffffffff8103659b ffff88003fd03dd8 ffff88003d3f0000 ffff88003e103d00
 0000000000000005 0000000000000001 ffff88003e0a9428 ffff88003fd03e38
Call Trace:
 <IRQ>  [<ffffffff8152f6eb>] dump_stack+0x19/0x1e
 [<ffffffff8103659b>] warn_slowpath_common+0x6b/0xa0
 [<ffffffff81036671>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff81471d6a>] dev_watchdog+0x25a/0x270
 [<ffffffff81471b10>] ? __netdev_watchdog_up+0x80/0x80
 [<ffffffff8104312c>] call_timer_fn+0x2c/0x90
 [<ffffffff81043369>] run_timer_softirq+0x1d9/0x1f0
 [<ffffffff8103d351>] __do_softirq+0xd1/0x1a0
 [<ffffffff8103d4c5>] irq_exit+0x65/0x80
 [<ffffffff81024399>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81533b0a>] apic_timer_interrupt+0x6a/0x70
 <EOI>  [<ffffffff8100a126>] ? default_idle+0x6/0x10
 [<ffffffff8100a2f6>] arch_cpu_idle+0x16/0x20
 [<ffffffff8106afd5>] cpu_startup_entry+0xa5/0x200
 [<ffffffff818c57ce>] start_secondary+0x267/0x269
---[ end trace d3a202af040f84f0 ]---
tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3D1400 enable_bit=3D2
tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3Dc00 enable_bit=3D2
tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3D1400 enable_bit=3D2
tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3Dc00 enable_bit=3D2

As far as I can tell the "tg3_stop_block timed out" is thrown when the
card is being reset after the hang timer expires and is quite harmless
(hope I'm reading it right). However said hangs do tend to be more
frequent as the amount of traffic rises, and that does interfere with
operation.

As a workaround, disabling scatter-gather on the offending cards stops
the problem from reappearing, however I'd like to get to the bottom of
this once and for all.

--=20

Cosmin GIRADU
OSS Engineer
RCS & RDS - Unified Services
Phone:  +40-31-400-6323
Mobile: +40-77-020-0858
http://www.rcs-rds.ro

=2E......................................................................=
=2E..
Privileged/Confidential Information may be contained in this message. If
you are not the addressee indicated in this message (or responsible for
delivery of the message to such person), you may not copy or deliver
this message to anyone. In such a case, you should destroy this message
and kindly notify the sender by reply e-mail.



--DM9vPe9CPQo6fc4tRjjRQwXHT0iKqDVvp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJR56udAAoJEKIzlqmspKc9L28H/iS2Nti0zF87Qax0OCen9BrY
idRYo289YWZB7hUmi5G5/oZc2HgEYZfxIavrpfPBtqpmL1i2gjI3IZyYLatICbVg
GlWX9dkSKiyfwQhpFovW49OXExPVpw3HJ/G6uUocTDtAScloPnjVtw6NpKX2lxDj
oyDdwT7QTPF99y57ZPQ3v/l99gQfM8WKzIkfxXlIjPcxwCfX+Iul5B27Q4+f3O2m
imFEWMCQZeNrReRD4xuLpH8NduH05VDPtAqNh/mmlifpkrAQbK6HD7tHCICJyYy/
1gpaDXkPyLeoVjD4CiSME2kAu+Aquo0/cTn1CWoOftGHs5BHp/75gvMSHdbrH3w=
=HYzR
-----END PGP SIGNATURE-----

--DM9vPe9CPQo6fc4tRjjRQwXHT0iKqDVvp--
