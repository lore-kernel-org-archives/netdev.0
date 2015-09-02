From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 06/19] ixgbe: Add support for VXLAN RX offloads
Date: Wed, 2 Sep 2015 16:53:33 +0000
Message-ID: <9A5A96DE-791A-4667-8B8B-F1ED3BDC2FB7@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1441156443-33381-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <CALx6S368wxfg63jDA85C9g319Jwd9ExPDTidPSZu89jhyYNgTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_1993A9E6-54A9-4EF2-B227-882C505F4EFA";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755534AbbIBQxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 12:53:35 -0400
In-Reply-To: <CALx6S368wxfg63jDA85C9g319Jwd9ExPDTidPSZu89jhyYNgTA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_1993A9E6-54A9-4EF2-B227-882C505F4EFA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 1, 2015, at 8:31 PM, Tom Herbert <tom@herbertland.com> wrote:
>=20
>> @@ -7240,6 +7267,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
>>                struct ipv6hdr *ipv6;
>>        } hdr;
>>        struct tcphdr *th;
>> +       struct sk_buff *skb;
>> +#ifdef CONFIG_IXGBE_VXLAN
>> +       u8 encap =3D false;
>> +#endif /* CONFIG_IXGBE_VXLAN */
>>        __be16 vlan_id;
>>=20
>>        /* if ring doesn't have a interrupt vector, cannot perform ATR =
*/
>> @@ -7253,16 +7284,36 @@ static void ixgbe_atr(struct ixgbe_ring =
*ring,
>=20
> Isn't this a function in the transmit path? What do these changes have
> to do with RX offloads?

Yes, it is in the transmit path. ATR sets up rules for delivering =
received packets to the correct queue. So this is setting things up for =
the receive side to work better. New hardware capabilities now make it =
possible to do this for VXLAN traffic.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_1993A9E6-54A9-4EF2-B227-882C505F4EFA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV5ymNAAoJEDwO/+eO4+5uuj8P/2EhZTHdWq7AG/Vg6WzuwgHF
nbsRKMORSldlSrsoUEJKE2nWf9Rs/bN+kXl9Nx5UAlLHatFQLhMCbSW4PRwFhzO4
iFdTCfxKU5aIZmhq4m6VFffyfloSxhtQItlwHhyt5B6ph84Uw1BWCcjfxfaDMu87
FE8OCIbz+vBXore1Mpeysl90vhdGzvyLjYMLXR3vzW23BaRbgij7ETHDOmU8MXpV
P9tnMgUhvEr4BxrX7f2bHe9UPG4sL+1GWWgSHyl+RnJJwxAfXBBP7Q2WwOzrhSsc
RZRt/leDDU4wBEnbZh5Yi9P1A6ArPhJB2/qElhrozT41124i+foP5SOo7C2gvBXX
8bHA2qsM51PGxsNUmNUsRW1umLISBgsHTFnt2TV5V4al3qSBnTs11lrMP0Ut9FB5
tJ60Ih4Cm222jLj09OdIyA/40y5sUZkMPVxkQGcJ6va0oH1//tpOLPCXwxJj5b+0
hpDFAr5gAEOGtCZ03wUQMNCJdCviV59agGa225bXXGJLiILBC4rMhBmvGKk07FXf
vfooi/YYTk/d6eI6KaXB6ckGjhiY3R18j3bnw3xGcxYQ3sy4bntfSR0L1IOP9veN
tu2i5YqOX+kBTeP2GVNzWFnPxpj/lQIeSQiQd11V1Oe92AB177F5yHjE0GONDj6G
lUCuXTiduhIcBd7gExox
=sERa
-----END PGP SIGNATURE-----

--Apple-Mail=_1993A9E6-54A9-4EF2-B227-882C505F4EFA--
