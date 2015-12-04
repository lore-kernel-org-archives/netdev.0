From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 10/17] fm10k: add TEB check to fm10k_gre_is_nvgre
Date: Fri, 04 Dec 2015 15:03:19 -0800
Message-ID: <1449270199.3224.89.camel@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1449188994-64940-11-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CALx6S35nF58aS1hR1MVtNQ8Y1iv5zt-OzMT_2dXSA5ysqPD7yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/9iGCWwhzo/6sp8bTi4g"
Cc: "David S. Miller" <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5572 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbbLDXDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 18:03:20 -0500
In-Reply-To: <CALx6S35nF58aS1hR1MVtNQ8Y1iv5zt-OzMT_2dXSA5ysqPD7yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/9iGCWwhzo/6sp8bTi4g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-03 at 16:54 -0800, Tom Herbert wrote:
> On Thu, Dec 3, 2015 at 4:29 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Jacob Keller <jacob.e.keller@intel.com>
> >
> > The NVGRE protocol should be run over transparent ethernet bridge
> > protocol, so we should verify this in our check whether the GRE
> tunnel
> > is NVGRE. While we're touching fm10k_main.c, update the copyright
> year.
> >
> > Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> > Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
> > Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >=C2=A0 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 +++++-
> >=C2=A0 1 file changed, 5 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> > index 746a198..c5f7e0d 100644
> > --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> > +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> > @@ -1,5 +1,5 @@
> >=C2=A0 /* Intel Ethernet Switch Host Interface Driver
> > - * Copyright(c) 2013 - 2014 Intel Corporation.
> > + * Copyright(c) 2013 - 2015 Intel Corporation.
> >=C2=A0=C2=A0 *
> >=C2=A0=C2=A0 * This program is free software; you can redistribute it an=
d/or
> modify it
> >=C2=A0=C2=A0 * under the terms and conditions of the GNU General Public
> License,
> > @@ -708,6 +708,10 @@ static struct ethhdr
> *fm10k_gre_is_nvgre(struct sk_buff *skb)
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (nvgre_hdr->flags & =
FM10K_NVGRE_RESERVED0_FLAGS)
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
> >
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* verify protocol is transparent=
 Ethernet bridging */
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (nvgre_hdr->proto !=3D htons(E=
TH_P_TEB))
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 return NULL;
> > +
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* report start of ethe=
rnet header */
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (nvgre_hdr->flags & =
NVGRE_TNI)
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 return (struct ethhdr *)(nvgre_hdr + 1);
>=20
> I don't understand this. Just because a packet is GRE with ETH_P_TEB
> set and only using keyid does not make it a GRE packet. What happens
> if someone creates a GRE tunnel on this same host with keyid and
> starts sending packets on it?
>=20
> BTW, these is a potentially similar issue in fm10k_port_is_vxlan.
> ndo_vxlan_port informs the driver of a vxlan port that may be
> received
> in a destination (presumably after the port has been bound for the
> tunnel). This says _nothing_ about source ports or the destination
> port. For instance, there is nothing that prevents an application
> from
> sending UDP packets to a "VXLAN port". If application does this, will
> it's packets be messed up by the offload misinterpreting the packets
> as VXLAN?
>=20
> As for this code:
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int hlen =3D ip_hdrlen(skb);
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* currently only IPv4 is supp=
orted due to hlen above */
>=20
> I'm just speechless ;-)

I was waiting for Jacob to respond, but I forgot he is on sabbatical
now. =C2=A0I can drop this patch from the series until someone is able to
address your questions/concerns.
--=-/9iGCWwhzo/6sp8bTi4g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWYhu3AAoJEOVv75VaS+3OafAQAJgC/PBy+bdk6PlP/q1vBQcp
b6mXtZJrU34VyEqd9RShaa04CFHe4krlPw6W6tHKS0Oui5X8L9pCJxZjxx1zDDkb
bzsMWj40EJn9Al4S9gOdz1mR79zbVu4eQ4e1+5YZrUc7QQkKbTOXjKwOT8x7lbe/
0z6avPxw4mdMuH42iyOeQeoLWQ5gc6EB00lipkSxpxi7+GktaWp5yFPhucIZTysU
nsSlvoQFC3Q5AtQIQYN5KSt35hWbM6yEECh+6cpzyNODC+PyaCcw5UBtgF2AbIiU
Rk1KllJZ4ArFH2pWBfEIbAE7UJxv9Lyfahqv70vcEZ3oPe9W3NbSy/jr2qlcP6Cm
P3CgKPHX9MnxO2omZE5v0vbr5HrPIzmF4K8DoqIk/5sbzzvJUaF6henPp97XqVs5
qhwi5ebqMjuyrL12Y6F3Ji6LZS8b8xV6+iQLTfoSld4NjgY+tvobfyOxSJgQV0TD
m2l+fdhpz7K+VUUAS4laGJI0mYsF5yX3ikMfafjWHlHmqXu3su6NPFuXCOVAP+kD
xfF2P84cXAESh5SWW/XsBjUFZIuzFTBFxTJGMH7brMOvlko/aUbsE203FdsV5nAl
YvRS9jVofxSXj04NkFNXEkXzf5THvJ6Az4O9sM0TXqQBDOnKF6QaCAgu+W1q0LLg
gGBdylvZlvMT3lg7cVkP
=nLdy
-----END PGP SIGNATURE-----

--=-/9iGCWwhzo/6sp8bTi4g--
