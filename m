From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40e: use ether_addr_equal_64bits
Date: Wed, 05 Mar 2014 20:40:45 -0800
Message-ID: <1394080845.2214.1.camel@jtkirshe-mobl>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394079704-1108-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394080559.12070.50.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-e/vo7GFZ3rkBt8s9LboN"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com,
	Kavindya Deegala <kavindya.s.deegala@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10963 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbaCFEk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:40:58 -0500
In-Reply-To: <1394080559.12070.50.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e/vo7GFZ3rkBt8s9LboN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-05 at 20:35 -0800, Joe Perches wrote:
> On Wed, 2014-03-05 at 20:21 -0800, Jeff Kirsher wrote:
> > From: Joe Perches <joe@perches.com>
> >=20
> > All ether_addr_equal tests in i40e can use the
> > slightly more efficient ether_addr_equal_64bits.
> >=20
> > All addresses passed to the various functions that
> > use ether_addr_equal are using structs that have 2
> > or more bytes of additional data after the mac addr
> > being tested.
>=20
> Hey Jeff.  Hi Kavindya.
>=20
> I don't know if these are really that important to convert.
>=20
> I did these when I looked for an example to convert and
> I thought "hey, 40 gig's fast, I should start there..."
>=20
> Recently, I've come to think that ether_addr_equal should
> be used almost exclusively and ether_addr_equal_64bits
> should only be used on performance sensitive or fast-path
> code.
>=20
> Are any of these on anything like a fast path or are
> performance sensitive?

Not sure if Kavindya has before and after performance numbers, hopefully
she does and can provide the numbers tomorrow.

>=20
> If not, maybe this patch should get tossed.
>=20
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/=
ethernet/intel/i40e/i40e_main.c
> []
> > @@ -997,7 +997,7 @@ static struct i40e_mac_filter *i40e_find_filter(str=
uct i40e_vsi *vsi,
> >  		return NULL;
> > =20
> >  	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> > -		if ((ether_addr_equal(macaddr, f->macaddr)) &&
> > +		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
> >  		    (vlan =3D=3D f->vlan)    &&
> >  		    (!is_vf || f->is_vf) &&
> >  		    (!is_netdev || f->is_netdev))
> > @@ -1025,7 +1025,7 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e=
_vsi *vsi, u8 *macaddr,
> >  		return NULL;
> > =20
> >  	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> > -		if ((ether_addr_equal(macaddr, f->macaddr)) &&
> > +		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
> >  		    (!is_vf || f->is_vf) &&
> >  		    (!is_netdev || f->is_netdev))
> >  			return f;
>=20
> Well, maybe these 2.
>=20
> > @@ -1214,7 +1214,7 @@ static int i40e_set_mac(struct net_device *netdev=
, void *p)
> > =20
> >  	netdev_info(netdev, "set mac address=3D%pM\n", addr->sa_data);
> > =20
> > -	if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
> > +	if (ether_addr_equal_64bits(netdev->dev_addr, addr->sa_data))
> >  		return 0;
> > =20
> >  	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
>=20
> probably not.
>=20
> > @@ -1417,21 +1417,24 @@ static void i40e_set_rx_mode(struct net_device =
*netdev)
> > =20
> >  		if (is_multicast_ether_addr(f->macaddr)) {
> >  			netdev_for_each_mc_addr(mca, netdev) {
> > -				if (ether_addr_equal(mca->addr, f->macaddr)) {
> > +				if (ether_addr_equal_64bits(mca->addr,
> > +							    f->macaddr)) {
> >  					found =3D true;
> >  					break;
> >  				}
> >  			}
> >  		} else {
> >  			netdev_for_each_uc_addr(uca, netdev) {
> > -				if (ether_addr_equal(uca->addr, f->macaddr)) {
> > +				if (ether_addr_equal_64bits(uca->addr,
> > +							    f->macaddr)) {
> >  					found =3D true;
> >  					break;
> >  				}
> >  			}
> > =20
> >  			for_each_dev_addr(netdev, ha) {
> > -				if (ether_addr_equal(ha->addr, f->macaddr)) {
> > +				if (ether_addr_equal_64bits(ha->addr,
> > +							    f->macaddr)) {
> >  					found =3D true;
> >  					break;
> >  				}
>=20
> probably not.
>=20
> > @@ -1905,7 +1908,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 =
vid)
> >  	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> >  		if (is_netdev) {
> >  			if (f->vlan &&
> > -			    ether_addr_equal(netdev->dev_addr, f->macaddr))
> > +			    ether_addr_equal_64bits(netdev->dev_addr,
> > +						    f->macaddr))
> >  				filter_count++;
> >  		}
>=20
> Dunno.
>=20


--=-e/vo7GFZ3rkBt8s9LboN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTF/xNAAoJEOVv75VaS+3O2MgP/2HKNdZf0NwxfdPHVOG4kbQd
gPHuYWbqi3/rUgJAss1fVWXFL/BuDyGmWt7b6ijd9HHLYTlFRT/g9Jp7ehB76vOn
knRYBhHbR6sQkZZdv3Np9r9Jyw/3GW33UpxL3QpAZDlKQFc0lxgm1nWMxXrlC7eq
xmQqrn8kOYLYKmRlessZJLWzswEbpWpylkVsNlURQBBFgorL1Ri+AqYW3Gk/tYjH
B/DAbDsMvvCmfbAaYOSnu8uANCWIWYJNoKquobRZgF1WBzhLJVn+kUFX5t3oL5+B
dQkJUAqkO1RcC1YrK/MLTwMJaUVa57iNCDwPnusgytb+xikJVOFBbtKoKSI1ZScv
WlwgZ8RRcU79oPqo7ekLO3G78u/FgVkIl2JCC5IhG/3FCZkEmGuCUwPWx2HDdxpw
GH9X2kklsUrC6eeaNWahliuzpTAsplL/3XHK/cNTSxx5NPJCHBRApVGxHBt3V8lJ
PiCz8aNG6eRquYdBGjespmUIg4MHrVs44/ZAd98FSTEOl6W+KUWRB84DNHZa1j58
o0+CnlQctGfVdxOBF2R8/dYr+vXIaJJCf06js6OoXpsbIAdB0cj8S90viGPqsvKb
RAj8xkvqPVKKTTIsk4n6eGli5eKCq5JQh2mbEQUg9cSirmwBdS9PxUrkqBPmxD1Y
dd3XOpI9ebY++TQ6mdEF
=lycH
-----END PGP SIGNATURE-----

--=-e/vo7GFZ3rkBt8s9LboN--
