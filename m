From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 06/15] i40e: Rx checksum offload for VXLAN
Date: Thu, 19 Dec 2013 11:17:30 -0800
Message-ID: <1387480650.2183.40.camel@jtkirshe-mobl>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387434891-19719-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZLfQu7vLN0fWEaW-KiKueUBtkRsp=ZqfffSz64FSpvgJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eRHcGrOGXB87DY2jMwBP"
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1174 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab3LSTRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 14:17:31 -0500
In-Reply-To: <CAJZOPZLfQu7vLN0fWEaW-KiKueUBtkRsp=ZqfffSz64FSpvgJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eRHcGrOGXB87DY2jMwBP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-12-19 at 19:46 +0200, Or Gerlitz wrote:
> On Thu, Dec 19, 2013 at 8:34 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> >
> > This implements receive offload for VXLAN for i40e.  The hardware
> > supports checksum offload/verification of the inner/outer header.
> >
> > Change-Id: I450db300af6713f2044fef1191a0d1d294c13369
> > Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
> >  drivers/net/ethernet/intel/i40e/i40e_main.c |  2 ++
> >  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 56
> ++++++++++++++++++++++++++---
> >  drivers/net/ethernet/intel/i40e/i40e_type.h | 51
> ++++++++++++++------------
> >  4 files changed, 82 insertions(+), 28 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e.h
> b/drivers/net/ethernet/intel/i40e/i40e.h
> > index 31dd265..3207568 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e.h
> > +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> > @@ -29,6 +29,7 @@
> >  #define _I40E_H_
> >
> >  #include <net/tcp.h>
> > +#include <net/udp.h>
> >  #include <linux/init.h>
> >  #include <linux/types.h>
> >  #include <linux/errno.h>
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > index b0cfb4c..7094ff7 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -27,6 +27,7 @@
> >
> >  /* Local includes */
> >  #include "i40e.h"
> > +#include <net/vxlan.h>
> >
> >  const char i40e_driver_name[] =3D "i40e";
> >  static const char i40e_driver_string[] =3D
> > @@ -3993,6 +3994,7 @@ static int i40e_open(struct net_device
> *netdev)
> >                                     "couldn't set broadcast err %d
> aq_err %d\n",
> >                                     err, pf->hw.aq.asq_last_status);
> >         }
> > +       vxlan_get_rx_port(netdev);
>=20
> what effect this has if  the driver doesn't implement the
> add_vxlan_port ndo entry?

It appears that there should have been a VXLAN for i40e from Joseph that
got pushed before this one, so I will re-send this series with necessary
patch added to the series.

--=-eRHcGrOGXB87DY2jMwBP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSs0ZKAAoJEOVv75VaS+3O2psQAJW3VEr2mBg1ADTP6UvN273k
afwCr8rdu1icwbliWzraxSVG5DFoJkH+DR8PoJQFA6TtXXyND4yIhpes+agIEyb7
R8IO/8YXvaJ+Etu34qPQ5geYW5Z8bSqGkj8c+kLkylk5VXn5Q4BPjgK7QjBS3ar6
bHJZP7HI0nuxSAPjmPa9OGn2kUB0xOZTMh4aGQGg5Jg16DqWCTwUxoAOH3P8kB4A
jgx6B43xBK0TUkVqbML6jY/JzqK8CdFmZQ3FZgrn0VR69oqsFTUVRYZ1iwdTzeRc
8SMsHsX5OarEL9B62XDZuNlzCq63vQt2Zkr4PsbzmIf5vS0dDX7mMFz2YbDCc3We
iU6uBSohY5ko7vm/YwdaNiSEujpVoAeqYhuvaLT+7IBbhvTsl3So78wbmbWuQEK8
GwS7mbr06KKP//yIPmEoIeuI2930xS5I/DA7sAFbChWZMaiec1c+SuoxICDJkfzZ
3rvXdAXVh1opvnjV+yxjTLMwAuQpssPdThT4R+VjQyubwKrWubWd/Qj6Kbnw3aKt
ci/eMUiRQXma5yYr3dUrTFRPrlxzK/b3JXR/k6okWTp6RBW7ek3IwHGn5+P1nPNj
CX/Qj9Ma+ixb50LdR8Nj6hArMsGk7HBXLuxTStzq+9cLDbBjWqdzkwVkQzXQ0K/S
WHQIWU5KPR23lGZzKpv+
=HRrO
-----END PGP SIGNATURE-----

--=-eRHcGrOGXB87DY2jMwBP--
