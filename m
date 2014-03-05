From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net RESEND] vlan: don't allow to add VLAN on VLAN device
Date: Wed, 05 Mar 2014 00:10:47 +0000
Message-ID: <1393978247.16256.27.camel@deadeye.wl.decadent.org.uk>
References: <530FF7BF.4030706@huawei.com> <53100677.2060705@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1D+2k3mML1dib6IMILwZ"
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53100677.2060705@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1D+2k3mML1dib6IMILwZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-27 at 19:45 -0800, John Fastabend wrote:
> On 2/27/2014 6:43 PM, Ding Tianhong wrote:
> > I run these steps:
> >
> > modprobe 8021q
> > vconfig add eth2 20
> > vconfig add eth2.20 20
> > ifconfig eth2 xx.xx.xx.xx
> >
> > then the Call Trace happened:
> >
>=20
> [...]
>=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > The reason is that if add vlan on vlan dev, the vlan dev will create vl=
an_info,
> > then the notification will let the real dev to run dev_set_rx_mode() an=
d hold
> > netif_addr_lock, and then the real dev will call ndo_set_rx_mode(), if =
the real
> > dev is vlan dev, the ndo_set_rx_mode() will hold netif_addr_lock again,=
 so deadlock
> > happened.
> >
> > Don't allow to add vlan on vlan dev to fix this problem.
> >
> > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> > ---
>=20
> I'm not sure we can just disable stacked vlans. There might be something
> using them today and they have worked in the past. Lets try to find a
> better fix.

I don't think there's any deadlock possible here.  We try to acquire the
addr_list_lock for eth2.20, then the addr_list_lock for eth2.  We never
try to acquire them in the opposite order.  The fix would involve
telling lockdep about lock ordering between stacked net_devices (I have
no idea how that's done).

Ben.

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-1D+2k3mML1dib6IMILwZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxZrh+e/yOyVhhEJAQpK2BAAkAwjaQd0UsTb1W7iwkBsOsZkCndU6oqV
FpNPUUL4DmZa2UMddEfVvAWump0TscZy7CWbc2GWYWo+kg8XUtlcfib3/bMMYoIq
xxdhJprDAgvOkJ/cO1fkDwUxahI6F/1UfAx3r8rNgZf/+dlgZ2ELMFKcvy59m8ja
2setoNK5tOu5/gm/LE/moPvNRicQgWsaJFt/8S7gfVmOB6yTvso9XfgFvJdV1QIg
2AYxmf20ZRXNcVigOOVYvYvEPuJjO+M6tFgjgZcAP8N6+Qb9X9T/Jt83rHhZQjJP
POe7zEvibX6SjVTSFElKFBzix6NdL3hzZOBr56PLBt+3fpvUoE2c8B+XZL/sz+Z2
XnUp5dgCzeCO9VpXJtmQ7A4lkP3l/5Al5MFiyv4nnLVmUKCJlPbR0Yml6WX41AIi
KxWO0HgBjVr79WaqX4GzYRB/aPP7KZCo3zj2+ijOs1eC2ckumTRF5e7taY24LEJ2
ZHXbcq0H5ntW7/cnhRFlepbedy+r0ap/8o07dmdQD6M/4hEnG9vwHNo0DetuuwZ+
/loVqac1Rrkx66xcb95atO7oAXHPKfnTjp3KweROwuj3Kp0LcPxCuK2vnJpohFr+
3Hf8OFugfv9CTqkXJH7dGavKw+U+BjlWDTW9Qtsj+VXzCIS97R8uCLBzun+agKgc
uNzTf+XVck4=
=MPZj
-----END PGP SIGNATURE-----

--=-1D+2k3mML1dib6IMILwZ--
