From: Harald Welte <laforge@netfilter.org>
Subject: ip_conntrack related slab error (Re: Fw: Re: 2.6.16-rc1-mm3)
Date: Tue, 31 Jan 2006 10:24:47 +0100
Message-ID: <20060131092447.GL4603@sunbeam.de.gnumonks.org>
References: <20060130221429.5f12d947.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KyQYs6ZyN5PqqdMo"
Cc: Reuben Farrelly <reuben-lkml@reub.net>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750728AbWAaJZH@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060130221429.5f12d947.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KyQYs6ZyN5PqqdMo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> Begin forwarded message:
>=20
> Date: Sat, 28 Jan 2006 00:47:06 +1300
> From: Reuben Farrelly <reuben-lkml@reub.net>
> To: Andrew Morton <akpm@osdl.org>
> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Subject: Re: 2.6.16-rc1-mm3
>=20
> Just triggered this one, which had a fairly bad effect on connectivity to=
 the box:
>=20
> i2c /dev entries driver
> slab error in kmem_cache_destroy(): cache `ip_conntrack': Can't free all =
objects
>   [<b010412b>] show_trace+0xd/0xf
>   [<b01041cc>] dump_stack+0x17/0x19
>   [<b0155d04>] kmem_cache_destroy+0x9b/0x1a9
>   [<f0ebf701>] ip_conntrack_cleanup+0x5d/0x10e [ip_conntrack]
>   [<f0ebe31e>] init_or_cleanup+0x1f8/0x283 [ip_conntrack]
>   [<f0ec2c4e>] fini+0xa/0x66 [ip_conntrack]
>   [<b0136d06>] sys_delete_module+0x161/0x1fb
>   [<b0102b3f>] sysenter_past_esp+0x54/0x75
> Removing netfilter NETLINK layer.
> [root@tornado log]#
>=20
> I was just reading IMAP mail at the time, ie same as I'd been doing for a=
n hour=20
> or two beforehand and not altering config of the box in any way.  I was a=
ble to=20
> log on via console but lost all network connectivity and had to reboot :(

The codepath you see in that backtrace is only hit during load or
removal of the 'ip_conntrack' module.  While this certainly still should
not oops, your description of 'not doing anything but IMAP reading' is
certainly not true. =20

Could you please describe what actually happened when that bug happened?
It looks to me that you were unloading ip_conntrack_netlink.ko followed
by ip_conntrack.ko.

> Generic details such as .config is at http://www.reub.net/files/kernel/

You don't have permission to access /files/kernel/ on this server.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--KyQYs6ZyN5PqqdMo
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD3yzfXaXGVTD0i/8RAmflAJ9l3V8XDCJrU6RvE4BR+YQno3ZMEgCfdwk9
b8RXGYdF6vLGOhMHn1r9pT0=
=zGaL
-----END PGP SIGNATURE-----

--KyQYs6ZyN5PqqdMo--
