From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 20:26:19 +0200
Message-ID: <20100316182619.GA3451@swordfish>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268752826.3094.48.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,
Got it right now.

System completely froze. Even SysRq didn't work.
/*spin_lock deadlock?*/

NOTE: I'm losing network constantly with pktgen tests
[24208.010980] r8169 0000:02:00.0: eth0: link up
[24220.010980] r8169 0000:02:00.0: eth0: link up
[24232.011030] r8169 0000:02:00.0: eth0: link up
[24340.010980] r8169 0000:02:00.0: eth0: link up
[24352.010966] r8169 0000:02:00.0: eth0: link up
[24364.010966] r8169 0000:02:00.0: eth0: link up
[24376.010964] r8169 0000:02:00.0: eth0: link up
[24388.010961] r8169 0000:02:00.0: eth0: link up
[24400.010959] r8169 0000:02:00.0: eth0: link up
[24412.010963] r8169 0000:02:00.0: eth0: link up


Traces:
[24600.625078] INFO: task events/0:9 blocked for more than 120 seconds.
[24600.625083] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[24600.625087] events/0      D 00001636     0     9      2 0x00000000
[24600.625096]  f7085ebc 00000046 a87e9490 00001636 c1617cc0 c1617cc0 c1617=
cc0 c1617cc0
[24600.625109]  f707c250 c1617cc0 c1617cc0 00000000 00000000 00000000 00000=
000 f707bfc0
[24600.625122]  c14745c8 c14745c8 f707bfc0 00000202 f7085efc c12c6449 00000=
000 00085edc
[24600.625135] Call Trace:
[24600.625148]  [<c12c6449>] __mutex_lock_common+0x233/0x3af
[24600.625155]  [<c12c65ff>] mutex_lock_nested+0x12/0x15
[24600.625163]  [<c1265e0f>] ? rtnl_lock+0xf/0x11
[24600.625168]  [<c1265e0f>] rtnl_lock+0xf/0x11
[24600.625183]  [<f9174acd>] rtl8169_reset_task+0x16/0xee [r8169]
[24600.625191]  [<c103c887>] worker_thread+0x161/0x233
[24600.625196]  [<c103c845>] ? worker_thread+0x11f/0x233
[24600.625205]  [<f9174ab7>] ? rtl8169_reset_task+0x0/0xee [r8169]
[24600.625214]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
[24600.625220]  [<c103c726>] ? worker_thread+0x0/0x233
[24600.625225]  [<c103f6ce>] kthread+0x6a/0x6f
[24600.625232]  [<c103f664>] ? kthread+0x0/0x6f
[24600.625238]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
[24600.625242] INFO: lockdep is turned off.
[24600.625259] INFO: task X:3176 blocked for more than 120 seconds.
[24600.625262] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[24600.625266] X             D 00000000     0  3176   3175 0x00400004
[24600.625273]  f6435a10 00003046 00025709 00000000 c1617cc0 c1617cc0 c1617=
cc0 c1617cc0
[24600.625286]  f60897d0 c1617c  ...=20
/*THE REST IS LOST*/



	Sergey


On (03/16/10 16:20), Eric Dumazet wrote:
> > [...]
> > >> NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> > Isn't it r8169 related?
> >=20
>=20
> This is tx side which seems blocked for more than 6 seconds.
>=20
> To really test the patch, you need following setup :
>=20
> machine A with r8169 NIC, patch applied, receiver of pktgen flood.
>=20
> machine B with any NIC, preferably a not buggy one, doing the pktgen
> flood to machine A
>=20
> If machine A survives, my patch is tested and ok.
>=20
> If machine B crashes, we have another problem to investigate
>=20
>=20

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkufzUsACgkQfKHnntdSXjRc5gQAuDdhfGviPj3Tf+eDItjtPrmN
cMWWCisPhaSMNdwNoS9KM27iDA0P5zELuY7eHC8MVn7qCIabfq57oSjMW6JaS7dq
ArrlouIyitxYDxN7byj6izpd8ipqRSvTWkVwF1D5snKqlAGgQLkS0e8klXh4Qq6h
Q42cPo/hAu231M9vDP8=
=jIfk
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
