From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/11][pull request] Intel Wired LAN Driver
 Updates 2014-11-18
Date: Tue, 18 Nov 2014 13:45:43 -0800
Message-ID: <1416347143.2295.25.camel@jtkirshe-mobl>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20141118.133829.2246481313976384106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hiDbYL/jIv5awjlXgAgv"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48145 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300AbaKRVpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 16:45:44 -0500
In-Reply-To: <20141118.133829.2246481313976384106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hiDbYL/jIv5awjlXgAgv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 13:38 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 18 Nov 2014 01:25:20 -0800
>=20
> > This series contains updates to i40e only.
> >=20
> > Shannon provides a patch to clean up the driver to only warn once that
> > PTP is not supported when linked at 100Mbps.
> >=20
> > Mitch provides a fix for i40e where the VF interrupt processing takes
> > a long time and it is possible that we could lose a VFLR event if it
> > happens while processing a VFLR on another VF.  To correct this situati=
on,
> > we enable the VFLR interrupt cause before we begin processing any pendi=
ng
> > resets.
> >=20
> > Neerav provides several patches to update DCB support in i40e.  When
> > there are DCB configuration changes based on DCBx, the firmware suspend=
s
> > the port's Tx and generates an event to the PF.  The PF is then
> > responsible to reconfigure the PF VSIs and switching topology as per th=
e
> > updated DCB configuration and then resume the port's Tx by calling the
> > "Resume Port Tx" AQ command, so add this call to the flow that handles
> > DCB re-configuration in the PF.  Allow the driver to query and use DCB
> > configuration from firmware when firmware DCBx agent is in CEE mode.
> > Add a check whether LLDP Agent's default AdminStatus is enabled or
> > disabled on a given port, and sets DCBx status to disabled if the
> > status is disabled.  Fix an issue when the port TC configuration
> > changes as a result of DCBx and the driver modifies the enabled TCs for
> > the VEBs it manages but does not update the enabled_tc value that=20
> > was cached on a per VEB basis.  Add a new PF state so that if a port's
> > Tx is in suspended state the Tx queue disable flow would just put the
> > request for the queue to be disabled and return without waiting for the
> > queue to be actually disabled.  Allows the driver to enable/disable
> > the XPS based on the number of TCs being enabled for the given VSI.
>=20
> Pulled, thanks Jeff.
>=20
> > v2: Dropped patch "i40e: Handle a single mss packet with more than 8 fr=
ags"
> >     while we rework the patch after we test a bit more based on feedbac=
k from=20
> >     Eric Dumazet.
>=20
> Since, as Eric showed, it's easy to hang the card with a simple
> netperf command line due to this issue, you might want to consider
> sending that fix to 'net' instead.

Got it, I have ear marked the revised patch for 'net'.

--=-hiDbYL/jIv5awjlXgAgv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUa74HAAoJEOVv75VaS+3O7PcP/RfiZ2ou5B7J7LrWaMMyJaPb
7vL4cnENcMf0NV0GBduQKbMEepKDMCXFU0dbQawn9zuQRpvsgxwfQ6AzeMWwCaM1
apY54QrcM6E0e34hzrzGRNG6UU8qQSn+i9OsZxh+ztB5uTMtjejT6leorm7xOYGF
eHZ5z4m3myg9umAp2yDJ/AVxV66xEOoXS6glmWJQnBX6nNZL9uGUKQfk2OBdf4dr
EJHjzwfxUHbdeie9ugN/G+IG615GcLytnQ8vTLqisvK7Xm9N1aErKlSyDfVaCEes
U3dPLmWUzkjJcp/qqvWPOfJu2cKSaXFo8Vuc48qUHrd7y1zJnN0eOLHsO99yHhLx
KF632bvGvIcufncgheyWeclKJMDyFsONkJXU0sx9nvxLj7rzDp4CZggeqHCd1Axe
LUlxh1b+BZ0l3XvpkDHCCXB9Dck3juJhvvWRoweAeS814OKf7a4pEvNjMCTjkQUt
bLTyykjDG9dxMsWz+V3tA0dxNhjywR0peB2DxHmcgt8Q6yguC6cZjp0Bi5eeNhYZ
CT6GHkFdSLy7roDrsH6baKI62DssbZrpebUeo6OYjZomkp3vnl//CU2yUbX7POPX
Be0dleF0MpulTzxxoGqxT0OTmbNb8O+CLlhGgy1yqeUw5GAP+3bxCB0OquCbSjC3
GVHzCEeqxZM/WDd0fFs/
=vfai
-----END PGP SIGNATURE-----

--=-hiDbYL/jIv5awjlXgAgv--
