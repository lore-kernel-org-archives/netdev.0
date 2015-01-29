From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: linux-next - crashes in rhashtable_shrink
Date: Thu, 29 Jan 2015 09:57:42 -0500
Message-ID: <5398.1422543462@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1422543462_1909P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1422543462_1909P
Content-Type: text/plain; charset=us-ascii

For the past few kernels, I've seen occasional crashes in rhashtable_shrink.
Looks like the last thing to touch that code was the patch series:

Subject	[PATCH 0/9 net-next v2] rhashtable: Per bucket locks & deferred table resizing
Date	Fri, 2 Jan 2015 23:00:13 +0100

Most common appears to be during boot, while ip6tables-restore is
running (though I admit I am not sure if ip6tables-restore was actually
running, or if it ended up hung because somebody else had died while holding
a lock.). But I have also seen it after 10-12 hours of uptime

[   53.762550] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   53.763607] IP: [<ffffffffab2a2898>] bucket_tail+0x57/0xaf

[   53.771622] Workqueue: events rht_deferred_worker
[   53.772715] task: ffff880224d20890 ti: ffff880224d24000 task.ti: ffff880224d24000

[   53.793546] Call Trace:
[   53.795374]  [<ffffffffab2a38fd>] rhashtable_shrink+0x13e/0x1a0
[   53.797197]  [<ffffffffab2a3a02>] rht_deferred_worker+0xa3/0xb4
[   53.798857]  [<ffffffffab058ef6>] process_one_work+0x2d8/0x54d
[   53.800070]  [<ffffffffab0594d8>] worker_thread+0x343/0x46b
[   53.801290]  [<ffffffffab059195>] ? process_scheduled_works+0x2a/0x2a
[   53.802513]  [<ffffffffab05e19d>] kthread+0xea/0xf2
[   53.803733]  [<ffffffffab6c50ba>] ? _raw_spin_unlock_irq+0x29/0x74
[   53.804957]  [<ffffffffab05e0b3>] ? __kthread_parkme+0xa8/0xa8
[   53.806176]  [<ffffffffab6c5a6c>] ret_from_fork+0x7c/0xb0
[   53.807400]  [<ffffffffab05e0b3>] ? __kthread_parkme+0xa8/0xa8
[   53.808609] Code: 4c 89 e7 e8 a1 ff ff ff 85 c0 75 1f 48 c7 c2 a9 89 b0 ab be 76 00 00 00 48 c7 c7 0d 61 b2 ab c6 05 a9 3d a3 00 01 e8 62 d6 dd ff <f6> 03 01 75 48 e8 d6 d7 de ff 85 c0 74 37 80 3d 90 3d a3 00 00
[   53.810092] RIP  [<ffffffffab2a2898>] bucket_tail+0x57/0xaf
[   53.811414]  RSP <ffff880224d27cc8>
[   53.812721] CR2: 0000000000000000
[   53.814033] ---[ end trace 82b77fc1a90284ff ]---

Unfortunately, I can't easily bisect to verify or narrow down further, as I'm only
seeing it 2-3 times a week....


--==_Exmh_1422543462_1909P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVMpKZQdmEQWDXROgAQJKMxAAsE5pIJNhXhsVN3XAheoLa/6Wup100EWF
MIyp26dsIRrp8WGxIxAICMFWOvWXmeqTubo/Bn8DFiO/wrygVemM0UKIs7JzcJr2
bF8aIMIPGNhFR4wGQ00JchwNTWeukTgxgDfIFKpGFaVgdd/lZAx37p+JuPSgwnn9
Dvr1q6NVBQ+mzi7jzclid9S5cYRC8BIS8DPyGka6BtYSK19LRoM+Gulzphps/1Yd
ZtIvw8T4PRm6gLCdLT2+sWJfqR9+y0nOCuc4t55TQkYi0yd9A3YqmQxup4lRuEfY
YSxIhfo75xoU2TOIc9XSXOH4w6/MwzSI15MZLvcKw0KVODjVlAYTk9oE/7uJSwDp
zXlAlLJMDGorX7ycBzpL+ENXFyiMTymdSGCIXL9Tiv1xuv1ApkgVMU/X8iuOw1UL
XI/rGC2fwdDTyo7koON+G/iKdGO/u0OH+c0MVPEo35VqwVexN8+lHAJO58n/4/Hi
ja2tsT6sBRlR2kRMiJK8Tu54qbNOw30Ti8xXo9bvc2S5mgSyzv9n2367/VfOdane
OHWHyINoiraXy/ko28cCHTEJL3TramPhnx0eRnaVnchXIHgLOyeOCYTvkOkUqJz/
XnMCY5/4yJPlymitFM/oEgPFk0tkBBGdjbGedGgbTB1fwcd7CBp38a8SPPVDu5lJ
Btk+vV04ofg=
=23yB
-----END PGP SIGNATURE-----

--==_Exmh_1422543462_1909P--
