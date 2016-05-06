From: Otto Sabart <osabart@redhat.com>
Subject: Re: ixgbe: cannot enable LRO
Date: Fri, 6 May 2016 12:18:58 +0200
Message-ID: <20160506101858.GC4106@redhat.com>
References: <20160427093646.GA15205@redhat.com>
 <CAKgT0UceTxomp+Zf5ks_B0bFomdx2jyhWLwSXh4716voJ5YFAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="MnLPg7ZWsaic7Fhd"
Cc: Netdev <netdev@vger.kernel.org>, Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbcEFKTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 06:19:00 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UceTxomp+Zf5ks_B0bFomdx2jyhWLwSXh4716voJ5YFAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MnLPg7ZWsaic7Fhd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> On Wed, Apr 27, 2016 at 2:36 AM, Otto Sabart <osabart@redhat.com> wrote:
> >
> > Hello everyone,
> > does anybody have a problem with LRO on ixge (on latest 4.6-rc5)?
> > I cannot find a way to enable it.
> >
> > On stable RHEL7.2 kernel everything works fine.
> >
> > I opened a bug report [0].
> >
> > [0] https://bugzilla.kernel.org/show_bug.cgi?id=3D117291
> >
> >
> > Thanks!
> >
> > Ota
>=20

Hello Alex,

> So I am able to turn on LRO without any issues.

Yes, I badly desciribed the problem. The LRO was not possible to turn on
immediately _after the boot_ (I was enabling it in /etc/rc.local).

When I reloaded the ixgbe driver, the LRO was possible to turn on
without problem.

I found out that the problem was caused by network manager. When I
disabled NM, the LRO started to work.

>=20
> Do you know if you have done anything that might disable LRO such as
> modified the rx-usecs to a value less than 10 or enabled routing or
> bridging on the device?  Also I think a stacked device might be able
> to block you from enabling LRO unless all the devices stacked on the
> interface can support it.

I did not modify rx-usecs (at least not intentionally).  Its value is
always (with disabled or enabled LRO) equal to 1 (with disabled NM).

$ ethtool -c ixgbe | grep rx-usecs
rx-usecs: 1
rx-usecs-irq: 0
rx-usecs-low: 0
rx-usecs-high: 0

There is no linux bridge or routing enabled on this device. There is
only a VLAN configured. Does it matter?

$ ip l show ixgbe
9: ixgbe: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode=
 DEFAULT qlen 1000
    link/ether 00:1b:21:90:c3:86 brd ff:ff:ff:ff:ff:ff

$ ip l show ixgbe.40
19: ixgbe.40@ixgbe: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueu=
e state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:90:c3:86 brd ff:ff:ff:ff:ff:ff


I updated the bugzilla [0] and I think we can close this as a NOTABUG.

Thanks!

Ota

--MnLPg7ZWsaic7Fhd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQFNBAABCgA3BQJXLG+OMBSAAAAAABUAEnBrYS1hZGRyZXNzQGdudXBnLm9yZ29z
YWJhcnRAcmVkaGF0LmNvbQAKCRAKSYXaOFQm4kBTCACHGPU8KIzqMaIg1aQpsa2Q
c+PT17PCC07GGXJ7FEEedjzWyb2YwEnVqVikMYhFhXzYZywK2UxUZwhILZZcH8gQ
JcdTWCQAxpM80axny4XCsmXUr77Lmt7CREHMYaJa7OC8yvXX/4I9gYSNWYoAK8F6
4XRVg9WP1fezgTUe3rxJ+8APsdS8m2FlZZgfxZ3Aoh7hTpVeJb2hJCQ+EFxMunYE
xET2iyyfvaatzdh7hWkZdgQT9sPhJphvO99uVn7w9bqIdf5KBzihHbZ4rGSAaRz/
NivZstEH0NcFdff8UQp1DL205DwZjWjqok6I/k+lmAC+TFzaFaOktesGWM78Op1P
=zrwT
-----END PGP SIGNATURE-----

--MnLPg7ZWsaic7Fhd--
