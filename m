From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: randconfig build error with next-20150302, in
 drivers/net/ethernet/intel/i40e/i40e_configfs.c
Date: Mon, 02 Mar 2015 15:03:54 -0800
Message-ID: <1425337434.2409.11.camel@jtkirshe-mobl>
References: <CA+r1ZhiO8i7b4XQatEX-9X12M9hYPo5F51wrOCYdA8JSMOHnpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zhAHmJaLjF1APSRyUtqs"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhiO8i7b4XQatEX-9X12M9hYPo5F51wrOCYdA8JSMOHnpg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zhAHmJaLjF1APSRyUtqs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-02 at 09:29 -0700, Jim Davis wrote:
> Building with the attached random configuration file,
>=20
> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> i40e_configfs.c:(.text+0x3df4ce): undefined reference to
> `config_item_init_type_name'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x3df4ee): undefined reference to `config_group_init'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x3df50c): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `i40e_configfs_exit':
> (.text+0x3df52e): undefined reference to `configfs_unregister_subsystem'
> Makefile:939: recipe for target 'vmlinux' failed

We found this issue and already have a patch to resolve the problem.
The issue is that we cannot have configfs as a module when our driver is
compiled into the kernel.  The solution is to use the similar Kconfig
logic we used for PTP (which had the same issue) for configfs.

I should have the patch pushed upstream in the next batch of patches I
push upstream.

--=-zhAHmJaLjF1APSRyUtqs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9OxaAAoJEOVv75VaS+3OgjAP/3c8QjYX3WbnzdJkzBGnofZf
iLD+DTpvjKWwf4Kr16XL3MrOvQ96++0AGwQOdbPqaSpsowQL3Xrs9oFmu6kS2B0J
Ff6+FoTSPXAIfG8Ye+qyYiIZYtDGU1KH43BjORSPL+fd1BHlYI6LZjJQtSuNbnaE
/KXDwob4WAD+l6QA1U8hCl2p0eakjl75byYMjYWfQBo1/zNdu4mPeoEmnb60CqS8
401r+oiRpIdQljdffxCzGJXf0IooN54jRDMfyFpiUSdS6FiTzTfTkKAMUaDtgBvZ
8rwyJiMEw0khKZVWWdXrEucQiQcqzQNTo/z/lwkbduVTpna1lE0oq4qvtb3H1o2g
MTghroh+0n6k8MPueSLb4hgJOl4EFqCoWKXt/jF/vfQfXeV/kHWcktbqx8z4T9Sg
WwSsUjqunyw5ZeziVxDYWM9dEvYE1rFxjGeesKgP69Raiw9Kwdj70oOjA6wjLQug
P9Tc9geqCCEzeefNbF0u98bN2QEMdAApWvyE5fvdbOSUWsw6U/x84eqgbeNw6vjG
KXxxxqe5VIsmxw+lotJiLVNbAIS9TJzrVjNPg0bq6whvb0w7p/REOG8e89HXKUbJ
H++hFXFnNAEalmfjlL/Drg7ed9mfyH/ov2iDgXIc6b4SCxlWwTqNbpmnhav2UHoL
5jP3DkiF2qduvKuPslli
=Hn+O
-----END PGP SIGNATURE-----

--=-zhAHmJaLjF1APSRyUtqs--
