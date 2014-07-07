From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: query: ethtool --show-nfc mask interpretation
Date: Mon, 07 Jul 2014 02:36:50 +0100
Message-ID: <1404697010.2902.85.camel@deadeye.wl.decadent.org.uk>
References: <alpine.LNX.2.03.1407042034540.7230@ws.cisco>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2e8qc3gW8RtniKvDquKC"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55809 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310AbaGGBcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 21:32:15 -0400
In-Reply-To: <alpine.LNX.2.03.1407042034540.7230@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2e8qc3gW8RtniKvDquKC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-07-04 at 21:43 +0530, Govindarajulu Varadarajan wrote:
> I was working on ethtool --show-nfc implementation for enic.
>=20
> While displaying, ethtool displays the 1's compliment of
> ethtool_rx_flow_spec->m_u.tcp_ip4_spec.psrc

The code in ethtool was originally written to work with the n-tuple
ethtool operations (which no longer exist) in which the mask fields
specify bits to be ignored in the packet.  For NFC rule operations, the
semantics are the opposite: the mask fields specify bits to be matched
in the packet.  So ethtool inverts the mask fields as necessary.

> I could not understand how to interpret the mask output
>=20
> For eg.
> [root@a163 linux-next]# ethtool -n enp9s0
> 8 RX rings available
> Total 2 rules
>=20
> Filter: 0
>          Rule Type: TCP over IPv4
>          Src IP addr: 10.65.79.1 mask: 255.255.0.0
>          Dest IP addr: 10.106.186.163 mask: 255.255.255.255
>          TOS: 0x0 mask: 0x0
>          Src port: 51331 mask: 0xff
>          Dest port: 22 mask: 0xffff
>          Action: Direct to queue 4
>=20
>=20
> The mask for src port is 0x00ff. Does that mean 8 bits in lsb should matc=
h and
> the other 8 bits in msb should be ignored? Or is it the other way?

It means the 8 least significant bits are ignored.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-2e8qc3gW8RtniKvDquKC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU7n5t+e/yOyVhhEJAQprBhAArr59vl4RbujSeiKTB8sPt3O6nG7S+RcM
Gw2x95Fj3LtwvrMrkQl3oP80wYdlfxELhCNMAWaajfd6MnKELboGNN1r2Ph6P83K
VrFAOeo9BC2KAZ424Gf8XXAlGFs6wtoYxdvG3Q0i5hRwH1TMHU3yTSvNwFOp+m1u
sGZRfv58ZOTAbkqJkJG8ghqH8BPQ/+VkA4EiKOzHHIkmzSj84MR0ZONYfpMzf+25
O5IE95ZMjwimAImY8LBFD3Wx2HDqCunQBmlAyKB7CbTvr75JlnHmWGu3LeTjoMCb
ocsVGPUt8hJAWoSiaHk6qZpTZBP0BRkNGLMOxyn2jDc63MRoh5ndMfdwPCCYlQZx
kVMmkF6fQH1eQ59bgy5k5lzxCdP9MnNAci6fx9SMUchzTIq3AcEQrA7CAZp/P7IN
BUoUMv1jlJerluKxeHv5P+iTs6GjyRJd7Qk76V7NmpqKW9pNibp0NJ+ettOAJf6y
cZdRvGxiGCFROYVevwS99l+uqRLCcEO1my6gXrXWa2TsdLX2ePMDEtsE+KLlx9my
rictNO8j3r+stSUnxi1WaIczdI5PsJruMwens1A65+8LjFuC9cZltSN8asTudgyK
VKE9gHTmQ9HhTf3obM63IeyHcazidsC7HSCJMVp5LFsrGc0xoEE2ljLoz4q7JGdY
t0VeoUdeRDA=
=ezoE
-----END PGP SIGNATURE-----

--=-2e8qc3gW8RtniKvDquKC--
