From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: WARNING: at net/batman-adv/hard-interface.c:92
 batadv_is_on_batman_iface()
Date: Sat, 30 Mar 2013 12:52:45 +0100
Message-ID: <20130330115245.GA4024@ritirata.org>
References: <20130330093635.GA31605@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130330093635.GA31605@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello all,

On Sat, Mar 30, 2013 at 05:36:35PM +0800, Fengguang Wu wrote:
> Greetings,
>=20
> I got the below WARNING in net-next/master (head commit f498354793d5)
> and the first bad commit is
>=20
> commit c54419321455631079c7d6e60bc732dd0c5914c5
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Mon Mar 25 14:49:35 2013 +0000
>=20
>     GRE: Refactor GRE tunneling code.
>    =20
>     Following patch refactors GRE code into ip tunneling code and GRE
>     specific code. Common tunneling code is moved to ip_tunnel module.
>     ip_tunnel module is written as generic library which can be used
>     by different tunneling implementations.
>    =20
>     ip_tunnel module contains following components:
>      - packet xmit and rcv generic code. xmit flow looks like
>        (gre_xmit/ipip_xmit)->ip_tunnel_xmit->ip_local_out.
>      - hash table of all devices.
>      - lookup for tunnel devices.
>      - control plane operations like device create, destroy, ioctl, netli=
nk
>        operations code.
>      - registration for tunneling modules, like gre, ipip etc.
>      - define single pcpu_tstats dev->tstats.
>      - struct tnl_ptk_info added to pass parsed tunnel packet parameters.
>    =20
>     ipip.h header is renamed to ip_tunnel.h
>    =20
>     Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> [   27.507156] libceph: loaded (mon/osd proto 15/24)
> [   27.515409] ------------[ cut here ]------------
> [   27.518917] WARNING: at /c/kernel-tests/src/stable/net/batman-adv/hard=
-interface.c:92 batadv_is_on_batman_iface+0x5c/0x7a()
> [   27.521935] Hardware name: Bochs
> [   27.525356] Cannot find parent device
> [   27.528296] Modules linked in:
> [   27.529923] Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc4-00896-g03ba9=
10 #794
> [   27.531747] Call Trace:
> [   27.534683]  [<ffffffff81098ab4>] warn_slowpath_common+0x83/0x9e
> [   27.536338]  [<ffffffff81098b72>] warn_slowpath_fmt+0x46/0x48
> [   27.537872]  [<ffffffff828e6402>] ? rcu_read_unlock+0x1c/0x2d
> [   27.539441]  [<ffffffff810ca498>] ? local_clock+0x19/0x52
> [   27.541023]  [<ffffffff82c0e796>] batadv_is_on_batman_iface+0x5c/0x7a
> [   27.542803]  [<ffffffff82c0efe2>] batadv_hard_if_event+0x8f/0x285
> [   27.544551]  [<ffffffff828e4ff0>] register_netdevice_notifier+0x71/0x1=
7e
> [   27.550617]  [<ffffffff8420a030>] ? batadv_iv_init+0x3f/0x3f
> [   27.552248]  [<ffffffff8420a114>] batadv_init+0xe4/0x104
> [   27.553770]  [<ffffffff810020be>] do_one_initcall+0x7f/0x13d
> [   27.555386]  [<ffffffff84177eb0>] kernel_init_freeable+0x141/0x1d0
> [   27.557177]  [<ffffffff84177734>] ? do_early_param+0x8c/0x8c
> [   27.558813]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
> [   27.560348]  [<ffffffff82c1f154>] kernel_init+0xe/0xdb
> [   27.561813]  [<ffffffff82c694ac>] ret_from_fork+0x7c/0xb0
> [   27.563356]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
> [   27.564974] ---[ end trace f78f9f0651ffcb0b ]---
>=20

The reason why batman-adv it raising this warning is because this call is
returning NULL:

dev_get_by_index(&init_net, net_dev->iflink);

net_dev is an interface that has been registered now and batman-adv is tryi=
ng to
analyse it to decide if it is a potential candidate for its virtual device =
or
not.

To the best of my knowledge, if the function above is returning NULL, it me=
ans
that the iflink attribute contains a broken value.

Am I wrong or iflink should never contain 0? If there is no parent device it
should contain the same value of ifindex. Right?


Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRVtINAAoJEADl0hg6qKeO5RQP/RxAikx4oL8Gvsw39nuUhy0t
T6bxiVB6p/aHwsZMNZMtYYVggTwAu6HDey7/xluAeu7xjz+alzUvEagA6TnGCSVw
I4h2TkR7xXSD2czaskmhLAzqS3AHqPV14MYdKxsCnaPV50S364qRy3/n54YOUcOY
+yhKNP3hqciXp9ke7vP4RGX0IYJRbYE8baHeBb3qzvp8f8DUOJF8CjpNNl4BFOdD
cFAVbwgsRJQZpf9b06zmzVu/tza2hxgosudV0OS+5xTSAvxrZQSQHRQs1SA7Zryh
ShSrzfR1eaLMj9ksW0YtJ2KZVbhboSlso+aI/ezvOKq2QmLTNvp6HCpVdRfYt9gS
/gxsUcZmHiQBaSMjVwxYRNF+thzyca3s3aFmQt5vjdJPVKbQAMW9KzWqbKDL6MJl
ZOQH+VzISrKHGSJP6+J6/gFNOm+7EotixsCGTzGe2zW99D7pFBbJww5Io7OIUvc9
ZKTqUvFx8fsqOe9/0NTJvrGsDlIxdoRvU74NEokNPbOjh6qQTBgXskccJCTkb2xh
wliEz1plABpblu4Sd3xAW7PLVpFcA+LtSM1+KCCnfO2f4l06nbnlsX7baSkupgq9
jITJzxUNJHVuVBx6vQxKDuiQo2UtAcqmxu/1kYpWIaid+OAy92a1SUruGkQpiNIV
j/cvPiePrYs6G6//PQ2L
=Gx0q
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
