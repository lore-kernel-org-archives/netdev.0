From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCHv3 net] i40e: Implement ndo_gso_check()
Date: Thu, 04 Dec 2014 11:20:16 -0800
Message-ID: <1417720816.2404.11.camel@jtkirshe-mobl>
References: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
	 <5480B1F0.9090407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u8MS4s+HN1vJycpTz1dK"
Cc: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org,
	linux.nics@intel.com, jesse@nicira.com,
	linux-kernel@vger.kernel.org, therbert@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5480B1F0.9090407@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-u8MS4s+HN1vJycpTz1dK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-12-04 at 22:11 +0300, Sergei Shtylyov wrote:
> Hello.
>=20
> On 12/04/2014 09:39 PM, Joe Stringer wrote:
>=20
> > ndo_gso_check() was recently introduced to allow NICs to report the
> > offloading support that they have on a per-skb basis. Add an
> > implementation for this driver which checks for IPIP, GRE, UDP tunnels.
>=20
> > Signed-off-by: Joe Stringer <joestringer@nicira.com>
> > ---
> > v3: Drop IPIP and GRE (no driver support even though hw supports it).
> >      Check for UDP outer protocol for UDP tunnels.
> > v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
> >      Add MAX_INNER_LENGTH (as 80).
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_main.c |   26 ++++++++++++++++++=
++++++++
> >   1 file changed, 26 insertions(+)
>=20
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/=
ethernet/intel/i40e/i40e_main.c
> > index c3a7f4a..0d6493a 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -7447,6 +7447,31 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb=
,
> >
> >   #endif /* USE_DEFAULT_FDB_DEL_DUMP */
> >   #endif /* HAVE_FDB_OPS */
>=20
>     Need empty line here, I think.

Nope, look above the #endif's, that is the blank line that you are
wanting if the above #ifdefs are defined and if not, the blank line is
before the #ifdef's.  So if you were to add a blank line as you
requested, there is a possibility of 2 blank lines in a row.  So it is
not needed.

>=20
> > +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev=
)
> > +{
> > +	if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) {
> > +		unsigned char *ihdr;
> > +
> > +		if (skb->protocol !=3D IPPROTO_UDP ||
> > +		    skb->inner_protocol_type !=3D ENCAP_TYPE_ETHER)
> > +			return false;
> > +
> > +		if (skb->inner_protocol =3D=3D htons(ETH_P_TEB))
> > +			ihdr =3D skb_inner_mac_header(skb);
> > +		else if (skb->inner_protocol =3D=3D htons(ETH_P_IP) ||
> > +			 skb->inner_protocol =3D=3D htons(ETH_P_IPV6))
> > +			ihdr =3D skb_inner_network_header(skb);
> > +		else
> > +			return false;
>=20
>     The above is asking to be a *switch* instead, no?
>=20
> > +
> > +#define MAX_TUNNEL_HDR_LEN	80
>=20
>     I'd #define this just above the function, if not at the start of the =
file...
>=20
> [...]
>=20
> WBR, Sergei
>=20
> _______________________________________________
> Linux-nics mailing list
> Linux-nics@intel.com



--=-u8MS4s+HN1vJycpTz1dK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUgLPwAAoJEOVv75VaS+3OQAYP/RNGuutfuKML0bL5+EhzOzNF
qk2EIQM/MXWSq2eVRzLADuML5FryDtkgmWsdyu1tmgvrnR4bZoGEjMLao9pLEFmA
/YePjh0SOLj22qmaiE9nM7yty9EYV4ftJWDDQ5a+ssHC40cuKX515/lEDpoSu5o5
roqOm1OOLPFdDyaKxzou++efief7XUB+6lvdtLByY7MeSbBhfdfFARr0ZcmYleMP
yA/tm/lL0fQYOICEwZ4NbZh6oV1tJO+H8EyfiR/3JdaMqNCYqlLbwZX5ht1oeXZU
B5gZMqRSFUIWCgV5h/xiL/PJTtFVhTBVlGZIUFDAa4WYFjfuJMvSnCmLvitSb9O0
mH4f6UY3o9UTv5HbYFtfS0Vn8kthZUxajlDv+DDW5FhH0UnpQW9E4U4rLFhKGqp4
HdXmiAqzYtkT8PQ0rooHbqRxBG/lB26Wq7PspELtFz1s5atO60x5lsjuYe2EIRbO
ozgWghZB8pcAYutcQDOrfVblD2xCYPfBrxJbCoL20XvZp16WkEf3aYgUJgC3uzz7
wvvZTX+k062H+I8S3uOmsNYJKSn8CgLTHLijzYgDQT1r5jmZPYAJE/S6zznaDu/U
DgLZTOpivcWesbFfi/zv6MGJqtpH4VBAN7BAKNm615c+Lyopsv3kXbpSCTqAR81O
Zkk2FMuqv0Of8jS4WG7S
=KxC/
-----END PGP SIGNATURE-----

--=-u8MS4s+HN1vJycpTz1dK--
