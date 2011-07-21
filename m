From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Wed, 20 Jul 2011 18:21:34 -0700
Message-ID: <1311211304.2401.9.camel@jtkirshe-mobl>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
	 <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>
	 <4D5D5AD8.5000802@candelatech.com>
	 <CAEP_g=_o7nP2FCnPufyT44JZZ+Z+jkcVpSa8Qj3mjPn+MwRhXA@mail.gmail.com>
	 <4E277267.8090702@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-s2gIGrWXXT4u2kNGM2bn"
Cc: Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24728 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613Ab1GUBVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 21:21:47 -0400
In-Reply-To: <4E277267.8090702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s2gIGrWXXT4u2kNGM2bn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-07-20 at 17:27 -0700, Ben Greear wrote:
> On 07/20/2011 05:18 PM, Jesse Gross wrote:
> > On Thu, Feb 17, 2011 at 9:28 AM, Ben Greear<greearb@candelatech.com>  w=
rote:
> >> On 02/17/2011 03:04 AM, Jeff Kirsher wrote:
> >>>
> >>> On Thu, Feb 10, 2011 at 13:59,<greearb@candelatech.com>    wrote:
> >>>>
> >>>> From: Ben Greear<greearb@candelatech.com>
> >>>>
> >>>> This allows the NIC to receive 1518 byte (not counting
> >>>> FCS) packets when MTU is 1500, thus allowing 1500 MTU
> >>>> VLAN frames to be received.  Please note that no VLANs
> >>>> were actually configured on the NIC...it was just acting
> >>>> as pass-through device.
> >>>>
> >>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
> >>>> ---
> >>>> :100644 100644 58c665b... 30c9cc6... M  drivers/net/igb/igb_main.c
> >>>>   drivers/net/igb/igb_main.c |    5 +++--
> >>>>   1 files changed, 3 insertions(+), 2 deletions(-)
> >>>>
> >>>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> >>>> index 58c665b..30c9cc6 100644
> >>>> --- a/drivers/net/igb/igb_main.c
> >>>> +++ b/drivers/net/igb/igb_main.c
> >>>> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct igb_ad=
apter
> >>>> *adapter)
> >>>>         adapter->rx_itr_setting =3D IGB_DEFAULT_ITR;
> >>>>         adapter->tx_itr_setting =3D IGB_DEFAULT_ITR;
> >>>>
> >>>> -       adapter->max_frame_size =3D netdev->mtu + ETH_HLEN + ETH_FCS=
_LEN;
> >>>> +       adapter->max_frame_size =3D (netdev->mtu + ETH_HLEN + ETH_FC=
S_LEN
> >>>> +                                  + VLAN_HLEN);
> >>>>         adapter->min_frame_size =3D ETH_ZLEN + ETH_FCS_LEN;
> >>>>
> >>>>         spin_lock_init(&adapter->stats64_lock);
> >>>> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_device
> >>>> *netdev, int new_mtu)
> >>>>   {
> >>>>         struct igb_adapter *adapter =3D netdev_priv(netdev);
> >>>>         struct pci_dev *pdev =3D adapter->pdev;
> >>>> -       int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS_LEN;
> >>>> +       int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HL=
EN;
> >>>>         u32 rx_buffer_len, i;
> >>>>
> >>>>         if ((new_mtu<    68) || (max_frame>    MAX_JUMBO_FRAME_SIZE)=
) {
> >>>
> >>> While testing this patch, validation found that the patch reduces the
> >>> maximum mtu size
> >>> by 4 bytes (reduces it from 9216 to 9212).  This is not a desired sid=
e
> >>> effect of this patch.
> >>
> >> You could add handling for that case and have it act as it used to whe=
n
> >> new_mtu is greater than 9212?
> >>
> >> I tested e1000e and it worked w/out hacking at 1500 MTU, so maybe
> >> check how it does it?
> >
> > I just wanted to bring this up again to see if any progress had been
> > made.  We were looking at this driver and trying to figure out the
> > best way to convert it to use the new vlan model but I'm not familiar
>=20
> I've been watching :)
>=20
> > enough with the hardware to know.  It seems that all of the other
> > Intel drivers unconditionally add space for the vlan tag to the
> > receive buffer (and would therefore have similar effects as this
> > patch), is there something different about this card?
> >
> > I believe that Alex was working on something in this area (in the
> > context of one of my patches from a long time ago) but I'm not sure
> > what came of that.
>=20
> Truth is, I don't really see why it's a problem to decrease the
> maximum MTU slightly in order to make it work with VLANs.
>=20
> I'm not sure if there is some way to make it work with VLANs
> and not decrease the maximum MTU.

This was the reason this did not get accepted.  I was looking into what
could be done so that we did not decease the maximum MTU, but I got
side-tracked and have not done anything on it in several months.

--=-s2gIGrWXXT4u2kNGM2bn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOJ38eAAoJECTsCADr/EWUFL8H/2wt/zWFQsumbdil8jHlvngk
Z/bgW18FzsEHAhW9uAcNYj3fnQrwAQWv8i3P/Cap9VO9UAvNB7YO0z865JN00qGs
m63VLoYZ0kOkrvdsog6Fzo/yhj7CfN/6PISqqe4uftLic98wlGBrtvY1AsAcpb2G
p5kwjdJVEdHmBOUzxA1ygtRqtjNNarS9m1ETyTuEKPYrep2iMcpLu0ZbP2gvDzSr
zhxozfoNlcKMPyuDFMjoMxon76rajaZId3Dw2XV0GD3J9qlzsnWnbDz+kGEz61Tz
D0kMpIKt5MSno2yXXxnuSukcfKZ7AepUMrucPrGeCvy5GJd2OO4jAe4Ua39rx0c=
=OD5i
-----END PGP SIGNATURE-----

--=-s2gIGrWXXT4u2kNGM2bn--

