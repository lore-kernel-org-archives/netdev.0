From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40e: use ether_addr_equal_64bits
Date: Thu, 06 Mar 2014 11:33:29 -0800
Message-ID: <1394134409.2214.27.camel@jtkirshe-mobl>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394079704-1108-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394080559.12070.50.camel@joe-AO722>
	 <1394080845.2214.1.camel@jtkirshe-mobl>
	 <CAP-MU4Nf=T-BZDpHnBzq8xcPf7CG3v2oMSD3fitAKXp=fP4XPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4LA2t/pUK6vBwAVaGoUN"
Cc: Joe Perches <joe@perches.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Kavindya Deegala <kavindya.s.deegala@intel.com>
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41676 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbaCFTda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 14:33:30 -0500
In-Reply-To: <CAP-MU4Nf=T-BZDpHnBzq8xcPf7CG3v2oMSD3fitAKXp=fP4XPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4LA2t/pUK6vBwAVaGoUN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 10:10 -0800, Shannon Nelson wrote:
> No, none of those uses are fast path.  I'd prefer we drop this patch.
> sln
>=20

Ok based on Joe's and Shannon's responses, I will drop this patch from
the series.

Dave- v2 of the series will be coming shortly.

>=20
> On Wed, Mar 5, 2014 at 8:40 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>         On Wed, 2014-03-05 at 20:35 -0800, Joe Perches wrote:
>         > On Wed, 2014-03-05 at 20:21 -0800, Jeff Kirsher wrote:
>         > > From: Joe Perches <joe@perches.com>
>         > >
>         > > All ether_addr_equal tests in i40e can use the
>         > > slightly more efficient ether_addr_equal_64bits.
>         > >
>         > > All addresses passed to the various functions that
>         > > use ether_addr_equal are using structs that have 2
>         > > or more bytes of additional data after the mac addr
>         > > being tested.
>         >
>         > Hey Jeff.  Hi Kavindya.
>         >
>         > I don't know if these are really that important to convert.
>         >
>         > I did these when I looked for an example to convert and
>         > I thought "hey, 40 gig's fast, I should start there..."
>         >
>         > Recently, I've come to think that ether_addr_equal should
>         > be used almost exclusively and ether_addr_equal_64bits
>         > should only be used on performance sensitive or fast-path
>         > code.
>         >
>         > Are any of these on anything like a fast path or are
>         > performance sensitive?
>        =20
>        =20
>         Not sure if Kavindya has before and after performance numbers,
>         hopefully
>         she does and can provide the numbers tomorrow.
>        =20
>         >
>         > If not, maybe this patch should get tossed.
>         >
>         > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>         b/drivers/net/ethernet/intel/i40e/i40e_main.c
>         > []
>         > > @@ -997,7 +997,7 @@ static struct i40e_mac_filter
>         *i40e_find_filter(struct i40e_vsi *vsi,
>         > >             return NULL;
>         > >
>         > >     list_for_each_entry(f, &vsi->mac_filter_list, list) {
>         > > -           if ((ether_addr_equal(macaddr, f->macaddr)) &&
>         > > +           if (ether_addr_equal_64bits(macaddr,
>         f->macaddr) &&
>         > >                 (vlan =3D=3D f->vlan)    &&
>         > >                 (!is_vf || f->is_vf) &&
>         > >                 (!is_netdev || f->is_netdev))
>         > > @@ -1025,7 +1025,7 @@ struct i40e_mac_filter
>         *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
>         > >             return NULL;
>         > >
>         > >     list_for_each_entry(f, &vsi->mac_filter_list, list) {
>         > > -           if ((ether_addr_equal(macaddr, f->macaddr)) &&
>         > > +           if (ether_addr_equal_64bits(macaddr,
>         f->macaddr) &&
>         > >                 (!is_vf || f->is_vf) &&
>         > >                 (!is_netdev || f->is_netdev))
>         > >                     return f;
>         >
>         > Well, maybe these 2.
>         >
>         > > @@ -1214,7 +1214,7 @@ static int i40e_set_mac(struct
>         net_device *netdev, void *p)
>         > >
>         > >     netdev_info(netdev, "set mac address=3D%pM\n",
>         addr->sa_data);
>         > >
>         > > -   if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
>         > > +   if (ether_addr_equal_64bits(netdev->dev_addr,
>         addr->sa_data))
>         > >             return 0;
>         > >
>         > >     if (test_bit(__I40E_DOWN, &vsi->back->state) ||
>         >
>         > probably not.
>         >
>         > > @@ -1417,21 +1417,24 @@ static void
>         i40e_set_rx_mode(struct net_device *netdev)
>         > >
>         > >             if (is_multicast_ether_addr(f->macaddr)) {
>         > >                     netdev_for_each_mc_addr(mca, netdev) {
>         > > -                           if
>         (ether_addr_equal(mca->addr, f->macaddr)) {
>         > > +                           if
>         (ether_addr_equal_64bits(mca->addr,
>         > > +
>         f->macaddr)) {
>         > >                                     found =3D true;
>         > >                                     break;
>         > >                             }
>         > >                     }
>         > >             } else {
>         > >                     netdev_for_each_uc_addr(uca, netdev) {
>         > > -                           if
>         (ether_addr_equal(uca->addr, f->macaddr)) {
>         > > +                           if
>         (ether_addr_equal_64bits(uca->addr,
>         > > +
>         f->macaddr)) {
>         > >                                     found =3D true;
>         > >                                     break;
>         > >                             }
>         > >                     }
>         > >
>         > >                     for_each_dev_addr(netdev, ha) {
>         > > -                           if (ether_addr_equal(ha->addr,
>         f->macaddr)) {
>         > > +                           if
>         (ether_addr_equal_64bits(ha->addr,
>         > > +
>         f->macaddr)) {
>         > >                                     found =3D true;
>         > >                                     break;
>         > >                             }
>         >
>         > probably not.
>         >
>         > > @@ -1905,7 +1908,8 @@ int i40e_vsi_kill_vlan(struct
>         i40e_vsi *vsi, s16 vid)
>         > >     list_for_each_entry(f, &vsi->mac_filter_list, list) {
>         > >             if (is_netdev) {
>         > >                     if (f->vlan &&
>         > > -                       ether_addr_equal(netdev->dev_addr,
>         f->macaddr))
>         > > +
>         ether_addr_equal_64bits(netdev->dev_addr,
>         > > +
>         f->macaddr))
>         > >                             filter_count++;
>         > >             }
>         >
>         > Dunno.
>         >
>        =20
>        =20
>=20
>=20
>=20
>=20
> --=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Mr. Shannon Nelson         Parents can't afford to be squeamish.



--=-4LA2t/pUK6vBwAVaGoUN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTGM2JAAoJEOVv75VaS+3OOZkP/277jSOGSm8Zw1Ju6YD9bI8P
jTtLOi7nugNVOClqTAVXAuF6ChQTqUNEGBc73ts8Cq0vwGn78SdxRujy2kFKIOZl
OKpsKHGH7zUwyVfs03ilpTeO+p0Sn2x5exvjUgeZEgOBVq5gBjF35oyTlfbC1Dbr
ENYgdv2yQrXspn6Fn5W7bOyf3O0vYnkq9wxJRH9WjApdiVtQ92Qs9W5+3Qd9V9OG
0ci/cvtTCe1Hmusx8u6+yGVsqUfzvnqvNc7KfRordNkk7evT731jO8Pdgd/PBSpq
sUJRckPxXEM9Ow//FeRwfBx8DWsJyE0WU9EN/Ho2k7mvltObHR0EeGxkk9CqraCD
I9JboanfF9eCT2ibNfYv9CgBncgYn87Sn5TtwiHHieCwDjSPP8+JY97SJi8q3FSj
EbQ3XoEhBEAzqhL5gLFay9dYvslKkBgQNBKOYRrXhKYMSvtRM1QwaAAU/dAo5Gz7
ehAYRuMnepdlZdCY0Y2YdSWa1K8UhhQtOtBO82HTBx8XeH0k3Gugc3v+5aK2kVxx
JjbHDw/mx5gyHQjj6hfan2GhTUrtx4uVQznnbGZNdMDJkPoiEHNTBT268f3nxEXt
ZIiOICoy2StKpZG3yUmZaefJBdN5ozIGrz32sPsAUcxeoPin3juvhPJLXYNhqN5x
G+0shnKCOUZllWl2clB+
=T+mj
-----END PGP SIGNATURE-----

--=-4LA2t/pUK6vBwAVaGoUN--
