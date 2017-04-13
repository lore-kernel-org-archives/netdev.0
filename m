From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 1/3] VSOCK: Add vsockmon tap functions
Date: Thu, 13 Apr 2017 16:01:33 +0100
Message-ID: <20170413150133.GG13387@stefanha-x1.localdomain>
References: <20170412160825.21037-1-stefanha@redhat.com>
 <20170412160825.21037-2-stefanha@redhat.com>
 <20170412163736.GB22692@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="S5HS5MvDw4DmbRmb"
Cc: netdev@vger.kernel.org, Zhu Yanjun <zyjzyj2000@gmail.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40974 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751212AbdDMPBl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 11:01:41 -0400
Content-Disposition: inline
In-Reply-To: <20170412163736.GB22692@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--S5HS5MvDw4DmbRmb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 12, 2017 at 07:37:36PM +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 12, 2017 at 05:08:23PM +0100, Stefan Hajnoczi wrote:
> > +int __vsock_remove_tap(struct vsock_tap *vt) {
> > +	bool found =3D false;
> > +	struct vsock_tap *tmp;
> > +
> > +	spin_lock(&vsock_tap_lock);
> > +
> > +	list_for_each_entry(tmp, &vsock_tap_all, list) {
> > +		if (vt =3D=3D tmp) {
> > +			list_del_rcu(&vt->list);
> > +			found =3D true;
> > +			goto out;
> > +		}
> > +	}
> > +
> > +	pr_warn("__vsock_remove_tap: %p not found\n", vt);
> > +out:
> > +	spin_unlock(&vsock_tap_lock);
> > +
> > +	if (found)
> > +		module_put(vt->module);
>=20
> This is called before synchronize_net so there might
> still be users for this tap.

Thanks, will fix.

--S5HS5MvDw4DmbRmb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY75LNAAoJEJykq7OBq3PIuQEH/2NPDz1XY6RmjLQI7x7RcUD2
d3z/5dYnk/LHYzwF9So4fVi9vUqXmW2EsbqJv970vfK7qFPFU5i1aKUCfQVvBFQk
WeRKu9g61uzzDMYdUsckHxiC9LJJrt/vTT1BcB4GGai1Y3pwX1GUlHNm5ru2Nboy
ibGelK6qHK8lgBEH/U4yDXA7JiZi+4CkXe4J2qZRLkMfsZF9jgudrpjyoJgca7BD
inMOAhXcLqsafjKbTKrf/TgCYmUznEdYhBHVRCeqiTWTwhs5CoXNvb2+srlpeT7w
Fiva6G3gxKuuPz2pI9mXMze9YxmDM3NAcREskBeQXjLpX3OnQBcBUddnnwaG++s=
=jWgA
-----END PGP SIGNATURE-----

--S5HS5MvDw4DmbRmb--
