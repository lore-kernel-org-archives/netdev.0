From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Thu, 1 Sep 2016 15:21:07 +0200
Message-ID: <57C82B43.80100@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be> <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be> <57C4554F.9000905@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="eb3h632QoQ43b2AQ634sOpQV3UJw0wxXO"
Cc: <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:57456 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753595AbcIANUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:20:34 -0400
In-Reply-To: <57C4554F.9000905@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--eb3h632QoQ43b2AQ634sOpQV3UJw0wxXO
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/29/2016 05:31 PM, Roopa Prabhu wrote:
> This looks fine. But, i am just trying to see if this can be rtnetlink.=

> Have you considered it already ?.
> We would like to keep the API consistent or abstracted to accommodate S=
R-MPLS in the
> future too. so, any abstraction there will help.
>=20
> what is your control-plane software using this ?
> quagga or any-other routing daemon ?
>=20
> Thanks,
> Roopa
>=20

rtnetlink is used for the routing part through the lwtunnels. In this
specific patch, the API is intended to configure namespace-wide
parameters such as a map of hmackeyid -> hashfn,secret, without
connection to particular routes. I agree that the tunsrc parameter could
be provided through rtnetlink, but the hmac data cannot (which by the
way does not exist for SR-MPLS).

The "control plane software" that currently uses that is simply a
patched version of iproute2 with SR support (which I will submit when
this patch series is hopefully merged). (e.g. ip sr set hmac blahblah)

More advanced control plane softwares are currently under development
and will be presented in upcoming academic publications.

David


--eb3h632QoQ43b2AQ634sOpQV3UJw0wxXO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfIK0MACgkQjbzn67sZ6AN+rwCfWPvx+UhqUA/8CrBT1LrOplMg
I3sAnArrAkkbdUDNIptntxEssLP81H6T
=aCOt
-----END PGP SIGNATURE-----

--eb3h632QoQ43b2AQ634sOpQV3UJw0wxXO--
