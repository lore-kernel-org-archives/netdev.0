From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 2/5] i40e: Implement ndo_gso_check()
Date: Wed, 05 Nov 2014 04:37:12 -0800
Message-ID: <1415191032.2420.58.camel@jtkirshe-mobl>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	 <1415138202-1197-3-git-send-email-joestringer@nicira.com>
	 <CAEP_g=8rbJF5z92LV_c14KooU=i3x=9WpikocctcEUOdw5-oLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8spS1Erg06Xywz+FEYYS"
Cc: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>, linux.nics@intel.com,
	amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, Tom Herbert <therbert@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=8rbJF5z92LV_c14KooU=i3x=9WpikocctcEUOdw5-oLA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8spS1Erg06Xywz+FEYYS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-04 at 15:45 -0800, Jesse Gross wrote:
> On Tue, Nov 4, 2014 at 1:56 PM, Joe Stringer <joestringer@nicira.com> wro=
te:
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/=
ethernet/intel/i40e/i40e_main.c
> > index c3a7f4a..21829b5 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev=
)
> > +{
> > +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> > +           (skb->inner_protocol_type !=3D ENCAP_TYPE_ETHER ||
> > +            skb->inner_protocol !=3D htons(ETH_P_TEB) ||
> > +            skb_inner_mac_header(skb) - skb_transport_header(skb) > 64=
))
> > +               return false;
>=20
> I think it may be possible to even support a few more things here.
> According to the datasheet here:
> http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xl=
710-10-40-controller-datasheet.pdf
>=20
> This can actually support 64 bytes beyond the tunnel header, which
> would make for a total of 80 bytes. It looks like it can also support
> IPv4 or IPv6 beyond just Ethernet as the encapsulated protocol.
>=20
> Intel guys, can you confirm that this is correct?

I believe you are correct Jesse, but I will let Shannon Nelson or Jesse
Brandeburg respond since they are the i40e maintainers.

--=-8spS1Erg06Xywz+FEYYS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUWhn4AAoJEOVv75VaS+3OQpoP/RnbHam+16LFUq214+YptlJO
J7ecwjqdFmdf7a40D/SwJEG8ANBcy2DQnZUl4QmD9lwrgDEEjqePabLwEvlWA3C4
GWYma4bVwoJnBV+0I9wgYM/UpG+wiX1X298dt4UytvRq6PvMnxPftmKkDu9cpZHC
qnUKq9UVhWmEx8T8m1qGQNXAXfLP1qE1AGJxfAYvwlqvmfgpZ0Npxk0dXdyxqA4A
Y0ErZ0vPBlFOyNYVFEKICiSzwY78qNFUBvEXUuuSfHfFov69LyT7o1BP/3o2b+Za
mR8TTSwqpswTdOrTJxu9umGEjLWDngOvWLQ8YQQoEuqlc4jAcOllMrf7GJE7/rva
oWtPw2WMFAqzAK8x38zJmfb8YTLFaS2DxbGIFjjZxAsL3vmfr1KPvXJLsLE8uP/z
XLn/7dBR70+9eaRkiyUFYp9gPe8bUGIt9J+hpx0ahJfKcZZCf5GhjDRBuWGAQ8wt
jlKaaqpwA7+AwaqxHO9qoayYpkWbiBHX5AgMwM4tOqBee7qOYyhxNzCz9/MoCYiX
ehGJr/fmfQx32Y9376uLsY0MUNe627oKcz/hqT2DwWoqRa1TS1K4NpEUv1SYhde+
FkFbp6VyLZhXJabzMPzo8QysJo59WQh5PeVqkqy7MInBbJ0iW9QBr0ySB0PxpIJU
CdB/vISD3ScO67SkVzWv
=HuEV
-----END PGP SIGNATURE-----

--=-8spS1Erg06Xywz+FEYYS--
