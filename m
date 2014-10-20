From: Kevin Fenzi <kevin@scrye.com>
Subject: localed stuck in recent 3.18 git in copy_net_ns?
Date: Mon, 20 Oct 2014 14:15:15 -0600
Message-ID: <20141020141515.0688bf33@voldemort.scrye.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/W7ZX13_K_7qj34KKUNZZUec"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/W7ZX13_K_7qj34KKUNZZUec
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Greetings.=20

I'm seeing suspend/resume failures with recent 3.18 git kernels.=20

Full dmesg at: http://paste.fedoraproject.org/143615/83287914/

The possibly interesting parts:=20

[   78.373144] PM: Syncing filesystems ... done.
[   78.411180] PM: Preparing system for mem sleep
[   78.411995] Freezing user space processes ...=20
[   98.429955] Freezing of tasks failed after 20.001 seconds (1 tasks refus=
ing to freeze, wq_busy=3D0):
[   98.429971] (-localed)      D ffff88025f214c80     0  1866      1 0x0000=
0084
[   98.429975]  ffff88024e777df8 0000000000000086 ffff88009b4444b0 00000000=
00014c80
[   98.429978]  ffff88024e777fd8 0000000000014c80 ffff880250ffb110 ffff8800=
9b4444b0
[   98.429981]  0000000000000000 ffffffff81cec1a0 ffffffff81cec1a4 ffff8800=
9b4444b0
[   98.429983] Call Trace:
[   98.429991]  [<ffffffff8175d619>] schedule_preempt_disabled+0x29/0x70
[   98.429994]  [<ffffffff8175f433>] __mutex_lock_slowpath+0xb3/0x120
[   98.429997]  [<ffffffff8175f4c3>] mutex_lock+0x23/0x40
[   98.430001]  [<ffffffff8163e325>] copy_net_ns+0x75/0x140
[   98.430005]  [<ffffffff810b8c2d>] create_new_namespaces+0xfd/0x1a0
[   98.430008]  [<ffffffff810b8e5a>] unshare_nsproxy_namespaces+0x5a/0xc0
[   98.430012]  [<ffffffff81098813>] SyS_unshare+0x193/0x340
[   98.430015]  [<ffffffff817617a9>] system_call_fastpath+0x12/0x17

[   98.430032] Restarting tasks ... done.
[   98.480361] PM: Syncing filesystems ... done.
[   98.571645] PM: Preparing system for freeze sleep
[   98.571779] Freezing user space processes ...=20
[  118.592086] Freezing of tasks failed after 20.003 seconds (1 tasks refus=
ing to freeze, wq_busy=3D0):
[  118.592102] (-localed)      D ffff88025f214c80     0  1866      1 0x0000=
0084
[  118.592106]  ffff88024e777df8 0000000000000086 ffff88009b4444b0 00000000=
00014c80
[  118.592109]  ffff88024e777fd8 0000000000014c80 ffff880250ffb110 ffff8800=
9b4444b0
[  118.592111]  0000000000000000 ffffffff81cec1a0 ffffffff81cec1a4 ffff8800=
9b4444b0
[  118.592114] Call Trace:
[  118.592121]  [<ffffffff8175d619>] schedule_preempt_disabled+0x29/0x70
[  118.592125]  [<ffffffff8175f433>] __mutex_lock_slowpath+0xb3/0x120
[  118.592127]  [<ffffffff8175f4c3>] mutex_lock+0x23/0x40
[  118.592132]  [<ffffffff8163e325>] copy_net_ns+0x75/0x140
[  118.592136]  [<ffffffff810b8c2d>] create_new_namespaces+0xfd/0x1a0
[  118.592139]  [<ffffffff810b8e5a>] unshare_nsproxy_namespaces+0x5a/0xc0
[  118.592143]  [<ffffffff81098813>] SyS_unshare+0x193/0x340
[  118.592146]  [<ffffffff817617a9>] system_call_fastpath+0x12/0x17

[  118.592163] Restarting tasks ... done.

root         6  0.0  0.0      0     0 ?        D    13:49   0:00 [kworker/u=
16:0]
root      1876  0.0  0.0  41460  5784 ?        Ds   13:49   0:00 (-localed)

I'll try and bisect this, but perhaps it rings bells already for folks.=20

kevin


--Sig_/W7ZX13_K_7qj34KKUNZZUec
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJURW1TAAoJEEs3sNgP+7te5v4QAJVLD5TPE35WjdwzjMY8nEJj
Lnto+AJPEooKsUHuPvA6FEA6JEgb2K/32IizoHPp0VCopFbe0Dyp+S778r0XZMMT
ZVOYFgF4AmfZ35kdrX7I3GgCExFcMnmOZxhDeEyVJYggwdhWaviVVakrimR7J113
Ftxl6MUU7+80LwfzgmJJRA6UVRR8nesMsaaXZsLRbgRV/bqQ3LBTNj3lcIrmcSwL
eVaIixvQ9tpwtuYXsXFz6zqL+gtq3xU4e0ds+kgFR1XKg7L/LegwzP0y9OFzZn6/
fx93akzMMcTqtlhbJVikcdzolbBihYWGTYhypZJAgXwme7zUmDmsKoD6Yn1cWAuS
7eXII8d5WVIfcq0sVO886J9Atfs3x+7WKoWBCkvHM24SCBh3DOGF/suzBrIhxfzE
w7dOxtIa7+0YYE19ZKQWApZ2QQkxI4YXP2ersJB2U64nVzNx+vDMTztZuseSKiCA
oBJEWyUIgXcxEz0w4Pk6pMacvzbbkoGVRC+J/ngNeAEsWN6jJZSTuVTnlq2JT//u
2NANupMlwhrygY3MFTq5mxXW09YZEGgS/SfDDqROG0rQ43BNrWesnHWcM7XFFf9h
Q57R56XcuGx2mSpJQgYMZ7/4HSrqBDdxNtIKYNh6mxRA4UwrpyiyLp7jOwfWdq4p
9n0hFEuZz2aBh1M5z3Wc
=L3U2
-----END PGP SIGNATURE-----

--Sig_/W7ZX13_K_7qj34KKUNZZUec--
