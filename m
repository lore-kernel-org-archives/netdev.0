From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
Date: Sat, 24 Sep 2011 22:47:51 -0700
Message-ID: <1316929672.2182.142.camel@jtkirshe-mobl>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-9PUY7CwX+yYIE9sQw/6j"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:15751 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab1IYFrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 01:47:52 -0400
In-Reply-To: <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9PUY7CwX+yYIE9sQw/6j
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-09-24 at 09:33 -0700, Jesse Gross wrote:
> On Sat, Sep 24, 2011 at 2:17 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Greg Rose <gregory.v.rose@intel.com>
> >
> > Changes to clean up the vlan rx path broke trunk vlan.  Trunk vlans in
> > a VF driver are those set using:
> >
> > "ip link set <pfdev> vf <n> <vlanid>"
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > CC: Jiri Pirko <jpirko@redhat.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 ++----
> >  1 files changed, 2 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/driver=
s/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index d72905b..4930c46 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -293,12 +293,10 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_=
vector *q_vector,
> >  {
> >        struct ixgbevf_adapter *adapter =3D q_vector->adapter;
> >        bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
> > +       u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
> >
> > -       if (is_vlan) {
> > -               u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
> > -
> > +       if (is_vlan && test_bit(tag, adapter->active_vlans))
> >                __vlan_hwaccel_put_tag(skb, tag);
> > -       }
>=20
> What happens if you run tcpdump without configuring vlan devices?
> Shouldn't you see tagged packets for the vlans that are being trunked
> to you?  I think this will strip tags in that case.  The apparent
> behavior of vlan filters here is also surprising to me because on one
> hand if they're truly filtering this test shouldn't be needed and on
> the other hand they don't seem to be disabled in promiscuous mode.

Jesse-

I believe this issue was noticed/reported by Jiri and I did not follow
it closely, so I would like Greg or Jiri to give you the information you
are wanting.  Being the weekend, I am sure Greg will respond come Monday
with more information.

Cheers,
Jeff

--=-9PUY7CwX+yYIE9sQw/6j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfsCHAAoJECTsCADr/EWUINgIAJHB+BKTGWhCEsnV5+gI/6dw
y/FX9s0z6d8yvOjZtb1O/n4WFksDLRacBcwPs/dG9qMjXs6CuvVwixQmy4WXX5oq
BVi6wCdhUztH9eDAKQkjv3J/3x22eJE4ZObmNgHufJwsE/N1xt1zE36Za3n2NRBC
q3e+uIb0AjHXcLp5xgCD0yWQTNVtzHiQiUva2hto6exZdnLJHCBdL+FMIysegvpF
5vwrkwn1PxVLqrIb0o/eP82npJ1qsFLEd/8JoD9LHtmXFb/xOuDbbV8Ox8oDE0t2
Cmh5daWJ6GTV++IhaL/J+kY1R97Xp2bpnsIULE7h5LMJ11pq+6ubc+vgIsM7JgE=
=7+LU
-----END PGP SIGNATURE-----

--=-9PUY7CwX+yYIE9sQw/6j--
