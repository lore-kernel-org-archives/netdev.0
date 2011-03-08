From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
Date: Mon, 07 Mar 2011 18:30:54 -0800
Message-ID: <1299551454.26413.42.camel@jtkirshe-MOBL1>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
	 <EA929A9653AAE14F841771FB1DE5A136602DEE63CB@rrsmsx501.amr.corp.intel.com>
	 <AANLkTikS7zw5OfPFTJBUeUyy39Tx26Wkg9FX3n77-v1G@mail.gmail.com>
	 <EA929A9653AAE14F841771FB1DE5A136602DF59AA3@rrsmsx501.amr.corp.intel.com>
	 <AANLkTikkMTv4uCbpOFfdgHzt2jMa5u5ipCOQ3OOh3KLs@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-SMU8D8r0iw3itxbHTqxh"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887Ab1CHCbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:31:13 -0500
In-Reply-To: <AANLkTikkMTv4uCbpOFfdgHzt2jMa5u5ipCOQ3OOh3KLs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SMU8D8r0iw3itxbHTqxh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-03-07 at 17:31 -0800, Jesse Gross wrote:
> On Tue, Jan 25, 2011 at 10:20 AM, Tantilov, Emil S
> <emil.s.tantilov@intel.com> wrote:
> >>-----Original Message-----
> >>From: Jesse Gross [mailto:jesse@nicira.com]
> >>Sent: Tuesday, January 25, 2011 9:23 AM
> >>To: Tantilov, Emil S
> >>Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> >>bphilips@novell.com; Pieper, Jeffrey E
> >>Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
> >>
> >>On Sun, Jan 23, 2011 at 4:25 PM, Tantilov, Emil S
> >><emil.s.tantilov@intel.com> wrote:
> >>> Jesse Gross wrote:
> >>>> On Thu, Jan 6, 2011 at 7:29 PM,  <jeffrey.t.kirsher@intel.com> wrote=
:
> >>>>> +static int ixgb_set_flags(struct net_device *netdev, u32 data) +{
> >>>>> +       struct ixgb_adapter *adapter =3D netdev_priv(netdev); +
> >>>>> bool need_reset; +       int rc;
> >>>>> +
> >>>>> +       /*
> >>>>> +        * TX vlan insertion does not work per HW design when Rx
> >>>>> stripping is +        * disabled.  Disable txvlan when rxvlan is
> >>>>> off. +        */ +       if ((data & ETH_FLAG_RXVLAN) !=3D
> >>>>> (netdev->features & NETIF_F_HW_VLAN_RX)) +               data ^=3D
> >>>>> ETH_FLAG_TXVLAN;
> >>>>
> >>>> Does this really do the right thing?  If the RX vlan setting is
> >>>> changed, it will do the opposite of what the user requested for TX
> >>>> vlan?
> >>>>
> >>>> So if I start with both on (the default) and turn them both off in o=
ne
> >>>> command (a valid setting), I will get RX off and TX on (an invalid
> >>>> setting).
> >>>>
> >>>> Why not:
> >>>>
> >>>> if (!(data & ETH_FLAG_RXVLAN))
> >>>>         data &=3D ~ETH_FLAG_TXVLAN;
> >>>
> >>> Yeah that works for disabling rxvlan, but what if rxvlan is disabled,=
 and
> >>the user attempts to enable txvlan? At least our validation argued that=
 we
> >>should make it work both ways. Perhaps something like the following?
> >>>
> >>>        if (!(data & ETH_FLAG_RXVLAN) &&
> >>>           (netdev->features & NETIF_F_HW_VLAN_TX))
> >>>                data &=3D ~ETH_FLAG_TXVLAN;
> >>>        else if (data & ETH_FLAG_TXVLAN)
> >>>                data |=3D ETH_FLAG_RXVLAN;
> >>
> >>I think the logic above does what you describe and will always result
> >>in a consistent state.  Turning dependent features on when needed is a
> >>little bit inconsistent with the rest of Ethtool (for example, turning
> >>on TSO when checksum offloading is off will not enable checksum
> >>offloading, it will produce an error).  However, I know that drivers
> >
> > That is the reason I asked, as I don't want to keep bouncing the patch =
back and forth. Personally I like the idea of helping the user and adjustin=
g the flags to something that works rather than a generic error message.
>=20
> Were you able to take a look at this?  I think that we have something
> that is pretty close, so it would be nice to wrap it up.

I have a patch which has passed testing from Emil, I just need to check
with Emil that the current patch I have ready to push is the "latest"
version and does not need any more tweaks.

Cheers,
Jeff

--=-SMU8D8r0iw3itxbHTqxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEbBAABAgAGBQJNdZTeAAoJECTsCADr/EWU3YEH91bO2Xfk9vL+HeoZsLmvn9/6
rPzG+pW1/tLpZ7yN3Ao5Hti7ebtmBDQUkLAB0bbvenBTxBW2p3mLVhku4T395/Wk
UdAqWbu7D5d72tNy3m5aXJMG4yqlPRhZcvnyM+z32rWd0WdoJBCInyWBN5WqtWAR
C7E93docMhemJtCHJoie/eNxqfuRN2ysbEqhxIsLcafyGEX6rPXOGKcJLqxd8IK/
Z+d+lKE0A7xQKHsL7KxamfASWe7DZSA/eOCVVxg7ifmRX6sB26RC+tax/KFyJRoJ
Y6tTpyoLCZlckirYb7RzCHD0/9b7SPfItoe3KR9MuxGK/eirEIZPsNu576x+Kg==
=Q/Zg
-----END PGP SIGNATURE-----

--=-SMU8D8r0iw3itxbHTqxh--

