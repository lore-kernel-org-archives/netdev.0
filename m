From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: RTL8192CU on ARM not working
Date: Thu, 27 Jun 2013 10:12:25 +0200
Message-ID: <20130627081225.GJ5803@lukather>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mPOSj6iWmtyhwOMz"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Brian Lilly <brian@crystalfontz.com>,
	Brent-Crosby <brent@crystalfontz.com>, Jim Wall <jimwall@q.com>,
	Thomas Petazzoni <thomas@free-electrons.com>
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mPOSj6iWmtyhwOMz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi everyone,

I'm currently trying to use a RTL8192CU on an ARM (Freescale imx28,
armv5) platform, using 3.10-rc3.

Trouble is, while the chip is correctly detected and you can use iw on it
without any problem it seems, once you start an association to an access
point, the association goes on, seems to associate, displaying a WARN()
message [1] and then, after what looks like a random amount of time (could
be right away, could be after a few minutes), deassociate [2].

During the time where it's associated, we never seem to transmit any
packets, while iw reports packets being sent, I guess we can assume that
they are actually never transmitted as well [3].

What seems odd to me as well is that the signal power reported for the acce=
ss
point is excessively high when using iw scan (10 dbm), and once connected, =
the
signal strength is -64dbm, which makes quite a huge difference.

Do you have any suggestions on how to solve this issue?

Thanks,
Maxime


[1]:
# iw wlan0 connect FreeWifi 2447
# [  485.010858] wlan0: authenticate with f4:ca:e5:c9:f5:91
[  485.065514] wlan0: send auth to f4:ca:e5:c9:f5:91 (try 1/3)
[  485.075963] wlan0: authenticated
[  485.088915] wlan0: associate with f4:ca:e5:c9:f5:91 (try 1/3)
[  485.117137] wlan0: RX AssocResp from f4:ca:e5:c9:f5:91 (capab=3D0x401 st=
atus=3D0 aid=3D1)
[  485.130607] wlan0: associated
[  486.917555] ------------[ cut here ]------------
[  486.922277] WARNING: at kernel/workqueue.c:1365 __queue_work+0x1f0/0x2f4=
()
[  486.929175] Modules linked in:
[  486.932284] CPU: 0 PID: 615 Comm: kworker/0:2 Not tainted 3.10.0-rc3 #2
[  486.938958] Workqueue: rtl92c_usb rtl_watchdog_wq_callback
[  486.944548] [<c00147dc>] (unwind_backtrace+0x0/0xf0) from [<c00120a0>] (=
show_stack+0x10/0x14)
[  486.953132] [<c00120a0>] (show_stack+0x10/0x14) from [<c001d2ec>] (warn_=
slowpath_common+0x4c/0x68)
[  486.962140] [<c001d2ec>] (warn_slowpath_common+0x4c/0x68) from [<c001d32=
4>] (warn_slowpath_null+0x1c/0x24)
[  486.971844] [<c001d324>] (warn_slowpath_null+0x1c/0x24) from [<c003769c>=
] (__queue_work+0x1f0/0x2f4)
[  486.981025] [<c003769c>] (__queue_work+0x1f0/0x2f4) from [<c0037830>] (q=
ueue_work_on+0x80/0x88)
[  486.989777] [<c0037830>] (queue_work_on+0x80/0x88) from [<c0267ca4>] (rt=
l_watchdog_wq_callback+0x5dc/0x8bc)
[  486.999572] [<c0267ca4>] (rtl_watchdog_wq_callback+0x5dc/0x8bc) from [<c=
0038cbc>] (process_one_work+0x1c0/0x4c8)
[  487.009795] [<c0038cbc>] (process_one_work+0x1c0/0x4c8) from [<c0039684>=
] (worker_thread+0x140/0x3ac)
[  487.019065] [<c0039684>] (worker_thread+0x140/0x3ac) from [<c003f914>] (=
kthread+0xa4/0xb0)
[  487.027381] [<c003f914>] (kthread+0xa4/0xb0) from [<c000f0c0>] (ret_from=
_fork+0x14/0x34)
[  487.035498] ---[ end trace 93341a0c249e647e ]---


[2]:

# [  786.086127] wlan0: deauthenticated from f4:ca:e5:c9:f5:91 (Reason: 2)
[  786.126368] cfg80211: Calling CRDA to update world regulatory domain


[3]:
# iw wlan0 station dump
Station f4:ca:e5:c9:f5:91 (on wlan0)
	inactive time:	55430 ms
	rx bytes:	77826
	rx packets:	1026
	tx packets:	2
	tx retries:	0
	tx failed:	0
	signal:  	-64 dBm
	signal avg:	-63 dBm
	tx bitrate:	1.0 MBit/s
	authorized:	yes
	authenticated:	yes
	preamble:	long
	WMM/WME:	yes
	MFP:		no
	TDLS peer:	no


--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--mPOSj6iWmtyhwOMz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRy/PpAAoJEBx+YmzsjxAgGgIP/2VmiorFlIS68NWNSOQ5/9pk
IryntlepA/YjNeAXeoxbyndFc0Yoy+cmFAEXGsM6ij8a+Yldam7WLAvmHl7fppDk
oDkkrMvXoO9oE5Xh3wQG7sKjV/NSKyml3WliAqLIJjz0I0uxPfQ3yL4V8eBPAyjf
6AgyA8EPt/Uyl8rjbrqmzUAWZloa9d36HjHoP59bQf2K5J5zPKjhjQ+4MjgA9k8j
AaRSTzi7tmZcDpc7m5zj2aRE6Bt7Z1Z3cwV6hr+irt6quK3B3R8aoDCnUQh6U5oz
KyU45uQ00YEDlpkMQ+YEmxBlRR1awFU1cqNGkLFrbl8Mvkfh969CjAoaTbCCzgCG
EAIxLK+Ent8yxdqSSIek3h2L7ea9mi0YCzjyzQ2JHYLJF3Qu1oC5RGdY9n+EM1k8
p7i6kp/rH5aZ5dC1AMszqkH3rXrRe9vO4Q+uvudxr/88lDMVckPZyNQZjjyImVyw
sRQcv8aznfGyFPpQo7DAfz9LCaqUQBO6lcXxYmCh1OKcB3kZugho9/fYakQDXaE5
lj8HbQgQKxSJ1L/YLMdaQMfvkILZnVJFwzKJj6ucIXQ/8HPmxaq54hJXcFd+vk/M
60Z7ZEAg/vCwPMJtyzMeMwhwot78iCmo3DDJpi9DHjb3E811rpuJi/QiBG7SQ3b7
FVOHdAKtsQBuGKafTkDJ
=tmFI
-----END PGP SIGNATURE-----

--mPOSj6iWmtyhwOMz--
