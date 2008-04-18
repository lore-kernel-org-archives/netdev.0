From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Fri, 18 Apr 2008 13:34:29 +0200
Message-ID: <200804181334.34229.laurentp@cse-semaphore.com>
References: <200804161640.42693.laurentp@cse-semaphore.com>
	<20080416160540.GB442@polina.dev.rtsoft.ru>
	<200804161809.40805.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0221171533=="
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200804161809.40805.laurentp@cse-semaphore.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0221171533==
Content-Type: multipart/signed;
  boundary="nextPart3467580.lIyNInjBNs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart3467580.lIyNInjBNs
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 16 April 2008 18:09, Laurent Pinchart wrote:
> On Wednesday 16 April 2008 18:05, Anton Vorontsov wrote:
> > On Wed, Apr 16, 2008 at 04:40:42PM +0200, Laurent Pinchart wrote:
> > > This patch converts the MII bitband driver to use GPIO lib for GPIO
> > > access. The driver can now handle MDC and MDIO on different GPIO bank=
s.
> > >=20
> > > The patch depends on Anton Vorontsov GPIO lib support scheduled for
> > > 2.6.26. It is by no means complete, I just would like to get some
> > > feedback on the approach. I'll resubmit it when the CPM2 GPIO support
> > > patches will be available in the powerpc git tree.
> >=20
> > Cool! By the way, maybe it is worth splitting it into completely separa=
te
> > driver, e.g. net/mdio_gpio.c?
>=20
> Splitting it into a completely separate driver makes sense.
>
> > Plus, keep in mind that somebody will eventually want this cool stuff w=
ith
> > platform_device bindings in addition. :-)=20
>=20
> I'm sure that person will be happy to implement platform_device bindings =
:-)

I had a first try at moving mdio gpio code into a separate driver.

Very little code is OF-independant, so the driver should probably be called=
=20
mdio_of_gpio.c or mdio_ofgpio.c.

Scott Wood was concerned in=20
http://patchwork.ozlabs.org/linuxppc/patch?id=3D17490 that the gpio lib mig=
ht=20
be an unnecessary burden for memory-constraint platforms. Should we keep tw=
o=20
mdio bitbang drivers, one with direct access to the ports and one using gpi=
o=20
lib ? The later solves the concurrent access issues present in the current=
=20
fs_enet mdio bitbang driber.

I'll submit a patch for whichever solution gets selected (modifying the=20
current fs enet mdio bitbang driver to use the gpio lib, or creating a new=
=20
driver).

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart3467580.lIyNInjBNs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBICIdK8y9gWxC9vpcRAr7PAKCIt21AmihWsIvGxygiqEfJMkDGCQCghddh
uM+IR/Bns8ILK7Inc/RBgzc=
=7Vam
-----END PGP SIGNATURE-----

--nextPart3467580.lIyNInjBNs--

--===============0221171533==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0221171533==--
