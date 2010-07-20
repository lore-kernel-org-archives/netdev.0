From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-07-19 - e1000e vs. pm_qos_update_request issues
Date: Tue, 20 Jul 2010 16:35:25 -0400
Message-ID: <6182.1279658125@localhost>
References: <201007200007.o6K07Xbg028863@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1279658125_4591P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org, Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:43659 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758174Ab0GTUgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:36:18 -0400
In-Reply-To: Your message of "Mon, 19 Jul 2010 16:38:09 PDT."
             <201007200007.o6K07Xbg028863@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1279658125_4591P
Content-Type: text/plain; charset=us-ascii

On Mon, 19 Jul 2010 16:38:09 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-07-19-16-37 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Throws a warning at boot:

[    1.786060] WARNING: at kernel/pm_qos_params.c:264 pm_qos_update_request+0x28/0x54()
[    1.786088] Hardware name: Latitude E6500
[    1.787045] pm_qos_update_request() called for unknown object
[    1.787966] Modules linked in:
[    1.788940] Pid: 1, comm: swapper Not tainted 2.6.35-rc5-mmotm0719 #1
[    1.790035] Call Trace:
[    1.791121]  [<ffffffff81037335>] warn_slowpath_common+0x80/0x98
[    1.792205]  [<ffffffff810373e1>] warn_slowpath_fmt+0x41/0x43
[    1.793279]  [<ffffffff81057c14>] pm_qos_update_request+0x28/0x54
[    1.794347]  [<ffffffff8134889e>] e1000_configure+0x421/0x459
[    1.795393]  [<ffffffff8134afbd>] e1000_open+0xbd/0x37c
[    1.796436]  [<ffffffff8105743a>] ? raw_notifier_call_chain+0xf/0x11
[    1.797491]  [<ffffffff8145f948>] __dev_open+0xae/0xe2
[    1.798547]  [<ffffffff8145f997>] dev_open+0x1b/0x49
[    1.799612]  [<ffffffff8146e36e>] netpoll_setup+0x84/0x259
[    1.800685]  [<ffffffff81b5037c>] init_netconsole+0xbc/0x21f
[    1.801744]  [<ffffffff81b5026c>] ? sir_wq_init+0x0/0x35
[    1.802793]  [<ffffffff81b502c0>] ? init_netconsole+0x0/0x21f
[    1.803845]  [<ffffffff810002ff>] do_one_initcall+0x7a/0x12f
[    1.804885]  [<ffffffff81b2ccae>] kernel_init+0x138/0x1c2
[    1.805915]  [<ffffffff81003554>] kernel_thread_helper+0x4/0x10
[    1.806937]  [<ffffffff81590e00>] ? restore_args+0x0/0x30
[    1.807955]  [<ffffffff81b2cb76>] ? kernel_init+0x0/0x1c2
[    1.808958]  [<ffffffff81003550>] ? kernel_thread_helper+0x0/0x10
[    1.809958] ---[ end trace 84b562a00a60539e ]---

Looks like a repeat of something I reported against -mmotm 2010-05-11, though a
WARNING rather than an outright crash - the traceback is pretty much identical.
 I have *no* idea why -rc3-mmotm0701 doesn't whinge similarly.


--==_Exmh_1279658125_4591P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMRgiNcC3lWbTT17ARAlVCAKDQUK86DgOXmSwr4HDgTQ+kMKyEJQCfZIcL
7jVWay0Ws6H7/jew9M6u9RI=
=jXbu
-----END PGP SIGNATURE-----

--==_Exmh_1279658125_4591P--

