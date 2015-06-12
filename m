From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: next-20150610 - repeated hangs at e1000e_phc_gettime+0x2e/0x60
Date: Thu, 11 Jun 2015 22:57:48 -0400
Message-ID: <21937.1434077868@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1434077868_2146P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1434077868_2146P
Content-Type: text/plain; charset=us-ascii

I'm seeing repeated hard lockups on my Dell Latitude E6530.
Helpful info:

0) next-20150603 works, so the problem landed in linux-next in the last week.

1) All 3 times happened while I was at home, using wireless, so
the interface didn't have link and was ifconfig'ed down.

2) Remarkably similar times for it to blow up:

[14513.365378] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 1
[14482.271716] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 3
[14479.906820] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 0

(I suspect the offsets were caused by differences in how long it took me
to correctly enter the cryptLUKS passphrase for my encrypted root filesystem)

Oddly enough, I don't see any patches to the e1000e driver in quite some
time... but that's where it keeps locking up.

This ringing any bells?

All 3 traces look like:

[14479.906908] Call Trace:
[14479.906914]  <NMI>  [<ffffffffba94db16>] dump_stack+0x50/0xa8
[14479.906930]  [<ffffffffba948bb9>] panic+0xcd/0x1e4
[14479.906940]  [<ffffffffba166a60>] ? perf_event_task_disable+0xc0/0xc0
[14479.906952]  [<ffffffffba125d8b>] watchdog_overflow_callback+0x9b/0xa0
[14479.906959]  [<ffffffffba16a684>] __perf_event_overflow+0xc4/0x1f0
[14479.906968]  [<ffffffffba16b3a4>] perf_event_overflow+0x14/0x20
[14479.906976]  [<ffffffffba022271>] intel_pmu_handle_irq+0x1e1/0x430
[14479.906990]  [<ffffffffba01a0f6>] perf_event_nmi_handler+0x26/0x40
[14479.906999]  [<ffffffffba0085b3>] nmi_handle+0x103/0x340
[14479.907005]  [<ffffffffba0084b5>] ? nmi_handle+0x5/0x340
[14479.907017]  [<ffffffffba008a53>] default_do_nmi+0xc3/0x120
[14479.907032]  [<ffffffffba008b98>] do_nmi+0xe8/0x130
[14479.907044]  [<ffffffffba95c9a8>] end_repeat_nmi+0x1e/0x2e
[14479.907055]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
[14479.907061]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
[14479.907069]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
[14479.907075]  <<EOE>>  [<ffffffffba0e9529>] timecounter_read+0x19/0x60
[14479.907088]  [<ffffffffba53687e>] e1000e_phc_gettime+0x2e/0x60
[14479.907098]  [<ffffffffba536a31>] e1000e_systim_overflow_work+0x31/0x70
[14479.907105]  [<ffffffffba07ad19>] process_one_work+0x3c9/0x980
[14479.907115]  [<ffffffffba07ac62>] ? process_one_work+0x312/0x980
[14479.907125]  [<ffffffffba07b348>] ? worker_thread+0x78/0x760
[14479.907134]  [<ffffffffba07b59c>] worker_thread+0x2cc/0x760
[14479.907144]  [<ffffffffba07b2d0>] ? process_one_work+0x980/0x980
[14479.907154]  [<ffffffffba082a5e>] kthread+0xfe/0x120
[14479.907163]  [<ffffffffba08ca50>] ? finish_task_switch+0x50/0x1c0
[14479.907173]  [<ffffffffba082960>] ? kthread_create_on_node+0x270/0x270
[14479.907179]  [<ffffffffba95ae4f>] ret_from_fork+0x3f/0x70
[14479.907188]  [<ffffffffba082960>] ? kthread_create_on_node+0x270/0x270
[14479.907243] Kernel Offset: 0x39000000 from 0xffffffff81000000 (relocation range:

--==_Exmh_1434077868_2146P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVXpKrAdmEQWDXROgAQLZfBAAsgwuCRCKl3ajEurGrkIIQ6Hikp5fIRPF
NUOMZU0Gv69gQ/v6XTqFSsKA6QVCnd9DyXxCsdh6mWLe1I4TCH45Y93rrtW3WBx7
He272NBFw3U7x03EDYYgTBsb1NAk3d2n/33/d/0ImfHMfXtSoA+DAVCnNKhvLnP6
bEcDkOjUEsXkRbUB0fwGeSAgew2ruzaujl/QL+/ocX0Y6aqoznLLrhWW4KXypbfV
g0/F7cIN5NaVjA+JPN6T7JIRdHmIZnofK0cJmFVeX+i+V9ZKH9hfk8gbCGzhMxfT
jgAqzu3PZaiF5a44r2PN2gNfdVhPTp/eVMnKGVexEiTOejmUe9rXYYKkiaR8Gf32
tXqf+cxOkJ2KhOgZSBsCT1z0gmxFQ0fPt0VFSHmxHUlzs83jvKUPUE4we9avKFy9
UJS1rDpYmJ/iarYzXrvu9E8ogrrAAJ5Q63eQpkv1k+AwvjPrvci6eRs+KTYIFM3f
SFsReLJR+XEbv7weBK6LVDPPntZgPmVWzLVVthBkwSQO+RlVGdZfFvm2agwTvwL1
tcSVhD4SgavsCZuLCMzC3M4Blvc1PTTKJ5h/CFA8G5Z0wBX0fxf8DgH5Sx2rNWYN
OseXc7TgFR+gc2fEZHn1HqD73BCbMLGlfvBVKZKSgpKapyOGdYHAkFcC0eYR/8uR
70v9zZBzx1A=
=/eTy
-----END PGP SIGNATURE-----

--==_Exmh_1434077868_2146P--
