From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] ixgbe: make VLAN filter conditional
Date: Fri, 06 Mar 2015 02:16:50 -0800
Message-ID: <1425637010.2556.180.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4EC48@BPXM14GP.gisp.nec.co.jp>
	 <1425634456.2556.160.camel@jtkirshe-mobl>
	 <7F861DC0615E0C47A872E6F3C5FCDDBD05E4F392@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QxF4I8szT8MnAlaC4tOm"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4F392@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QxF4I8szT8MnAlaC4tOm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 09:46 +0000, Hiroshi Shimamoto wrote:
> > On Fri, 2015-03-06 at 06:04 +0000, Hiroshi Shimamoto wrote:
> > > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > >
> > > > Disable hardware VLAN filtering if netdev->features VLAN flag is
> > > dropped.
> > > >
> > > > In SR-IOV case, there is a use case which needs to disable VLAN
> > > filter.
> > > > For example, we need to make a network function with VF in
> > > virtualized
> > > > environment. That network function may be a software switch, a
> > > router
> > > > or etc. It means that that network function will be an end point
> > > which
> > > > terminates many VLANs.
> > > >
> > > > In the current implementation, VLAN filtering always be turned on
> > > and
> > > > VF can receive only 63 VLANs. It means that only 63 VLANs can be
> > > terminated
> > > > in one NIC.
> > > >
> > > > With this patch, if the user turns VLAN filtering off on the host,
> > > VF
> > > > can receive every VLAN packet.
> > > >
> > > > This VLAN filtering can be turned on or off when SR-IOV is disabled=
,
> > > if not
> > > > the operation is rejected.
> > >
> > > Hi,
> > >
> > > any comment about this?
> > > I added a warning message and prevent operation during SR-IOV is
> > > enabled.
> >=20
> > Yes, the warning message you added says nothing of the huge security
> > hole this exposes.  We need a message the correctly expresses the
> > dangers in turning this off.
>=20
> hm okay.
> Do you mean I should add a message like "this causes SECURITY issue", rig=
ht?

Correct, you will need to notify the user that by turning off VLAN
filtering, this opens up serious security issues.  The message should
well inform the user of the potential dangers, so that if someone gets
hacked or information gets stolen because they turning off VLAN
filtering, that is was due to their choice to turn off this feature and
not a design flaw in the driver.

> >=20
> > Also it does not appear that you addressed Ben Hutchings concerns, as I
> > asked.  Correct me if I am wrong and you did address Ben's concerns.
>=20
> I think Ben's suggestion is to prevent turn VLAN filtering back on during
> VFs are used because that breaks guest's behavior.
> I added the code that make it impossible. We cannot turn on (or off) if
> the NIC has VFs.

And notify them that one they turn it off, then cannot turn it back on
if the NIC has VFs, so they will remain exposed and will continue to
have serious security issues.

>=20
> thanks,
> Hiroshi



--=-QxF4I8szT8MnAlaC4tOm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU+X6SAAoJEOVv75VaS+3OxHIP/2rnAMXfmtTFnBgV949s/qhB
Oxn7PZiTE0aGk/QEzqkFEy+xXwhKl5ueW3kQqY87+PPntAm4KvvVIZPO33NNuXJq
TD9sUm9KtVeO0uuiElMLmnEtIefIhMUGY8nC5LIQDvynESYYGnjMeSPCWZqekCVn
w2OmO6khoSA5ezWyBwhIVFyaLd5G+I4NfJ/CFSDGywkUX+QlRovLjthQTLgXQ3LL
RTzTgBPuZarv88s0xJU/zXVyxf5/nz13O6TeIvGUEJK1oMBoIHFS4NlFkCPjVYBS
w8GUkZHbwZf6iZjvIu9/EYYIsMZnYNNKpqW524CC+hBVJYe5o0b0X4S2WOwc7iDA
IELaP3VcXWSXR2o/Vcgf9uSw80GYgnYHGPnDI5hPgZhd5+1w5zGu0eORQOKuiqu7
e3eXRT3bPDn5dRPhBasNXL5FMz//Jq/Lvtt81nOehzRFWf6otHtRpf/JDJmFdFRG
fUI9rRI06kyU1cvIMQmTudCqjbhi/lOSPfkkh2bQAL2LQ/8mDSZCg4/0XiYCA7ph
bTAKjfmxrW6PZ7Oxa8XirFO7U7Ed8zeFmhDjqsoPkOYUK8VTwLc0W4RNU5Ck8Nj9
/sWrr8W/8MtlW0P+N6UJqqJ25CEQ0a5iFFA39qHItqifTqwy4L4j0ZjHhJLeS3pA
Bw9X0H+9bkGUYT3Wt//O
=oVeZ
-----END PGP SIGNATURE-----

--=-QxF4I8szT8MnAlaC4tOm--
