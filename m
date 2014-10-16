From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
Date: Thu, 16 Oct 2014 00:32:30 -0700
Message-ID: <1413444750.2412.43.camel@jtkirshe-mobl>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
	 <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
	 <87618083B2453E4A8714035B62D67992500E2629@FMSMSX105.amr.corp.intel.com>
	 <543F7255.7070606@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3/rSHbTpEPGf1BW/FXDL"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thierry Herbelot <thierry.herbelot@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31822 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbaJPHcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 03:32:36 -0400
In-Reply-To: <543F7255.7070606@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3/rSHbTpEPGf1BW/FXDL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-10-16 at 09:23 +0200, Thierry Herbelot wrote:
> On 10/16/2014 12:50 AM, Tantilov, Emil S wrote:
> >> -----Original Message-----
> >> From: Thierry Herbelot [mailto:thierry.herbelot@6wind.com]
> >> Sent: Wednesday, October 15, 2014 2:58 AM
> >> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
> >> netdev@vger.kernel.org; Tantilov, Emil S
> >> Cc: Thierry Herbelot
> >> Subject: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereferenc=
e
> >>
> >> this protects against the following panic:
> >> (before a VF was actually created on p96p1 PF Ethernet port)
> >>
> >> ip link set p96p1 vf 0 spoofchk off
> >> BUG: unable to handle kernel NULL pointer dereference at 0000000000000=
052
> >> IP: [<ffffffffa044a1c1>]
> >> ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
> >>
> >> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> >> ---
> >>
> >> v2:
> >>   compilation fixes
> >>
> >> v3:
> >>   remove checks in functions where vfinfo is known not to be NULL
> >>   return -EINVAL as error code
> >>
> >> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   42
> >> ++++++++++++++++++++++--
> >> 1 file changed, 40 insertions(+), 2 deletions(-)
> >
> > Actually looking into this a bit more, the check for vfinfo is not suff=
icient
> > because it does not protect against specifying vf that is outside of sr=
iov_num_vfs range.
> >
> > All of the ndo functions have a check for it except for ixgbevf_ndo_set=
_spoofcheck().
> >
> > The following patch should be all we need to protect against this panic=
:
> >
> > This patch adds a check to return -EINVAL when setting spoofcheck on
> > VF that is not configured.
> >
> > Reported-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> > Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> > ---
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    3 +++
> >   1 file changed, 3 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_sriov.c
> > index 706fc69..97c85b8 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > @@ -1261,6 +1261,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *=
netdev, int vf, bool setting)
> >   	struct ixgbe_hw *hw =3D &adapter->hw;
> >   	u32 regval;
> >
> > +	if (vf >=3D adapter->num_vfs)
> > +		return -EINVAL;
> > +
> >   	adapter->vfinfo[vf].spoofchk_enabled =3D setting;
> >
> >   	regval =3D IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
> >
> >
>=20
> Hello,
>=20
> Indeed your patch solves the initial issue.
>=20
> And indeed I also double-checked that all other instances are protected=
=20
> by the (vf >=3D adapter->num_vfs) condition.

So Thierry, can I add your Acked-by or Tested-by to Emil's patch?

--=-3/rSHbTpEPGf1BW/FXDL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUP3SOAAoJEOVv75VaS+3O2PMP/RTKsMSSsFfYzibLG7KWtkM7
4Jj6PKPowWJBfmaV+EPPdBedu6g0LK75wP4H7NkelmDT0rd2+FzC/MgoHp9z2y4I
0gZNatiehFI2XVkmuYGs3HKD4BiGFwMnEGC2T5GhrdM3qdUeeNwj6sBXkBlEaQqO
fAH+HveajZlV9C9XyCuJtAmAefnHKSQCPmzO4Ehitb3IwHJ2+IGelrx9hZ7YfzSO
v7PdcSb66dVGNxK1C2MyJElcm4beo3dcNl5bYq0t3JTvTxriIerhOvryZKp+wA3c
xLN6VIzW94zTKXeF5qDOSF76s8gH0ru0ZxGWIIi8GhrzMN1aNAepKRmErQKQ6MiS
ekoLuOwhb1WQpz3Q3cAZib2M9QPhGt37crnYTf8EyWj2oZD2Ap5e+7unYSRXJYAP
BZ/GlY07zynvdFTfly1o0gLLMT3+V79z94wJB1BagA9UuuCVUX6xnL1P8/wZLNod
0MEnScYLgQnCZDYHi9LBCqv4LB2AvUrFM4Q0Yjzll3b2sNGXTzMron3U1sKZ4w22
dEiQ2BYY3FfnTe3/cR0u9EXNwW3ZQ/Cr1/C9FipFUcHiLUL60Eq8qQoejz+LwsKV
k989M0I2G55AFLnhx84jEkNgqfiJ4hJ932lK7/QgaIuEroNL8GnaSIxknXWFnN3F
YNWvvmshQilSnxKJPqXh
=cbu6
-----END PGP SIGNATURE-----

--=-3/rSHbTpEPGf1BW/FXDL--
