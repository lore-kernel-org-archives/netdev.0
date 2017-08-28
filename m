From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH] ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC
 8200"
Date: Mon, 28 Aug 2017 19:48:15 +0100
Message-ID: <b84d5301-ba0a-f23a-4f8a-697e3cad1fae@uclouvain.be>
References: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="EbACec4fA0GumBpAq0Vm54UgSWm6IBBMx"
Cc: <yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>
To: Ahmed Abdelsalam <amsalam20@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39295 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdH1Srp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:47:45 -0400
In-Reply-To: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--EbACec4fA0GumBpAq0Vm54UgSWm6IBBMx
Content-Type: multipart/mixed; boundary="8fxamJTnWr8Sew6PH9UhrPcGODDHhScqR"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Ahmed Abdelsalam <amsalam20@gmail.com>, davem@davemloft.net
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Message-ID: <b84d5301-ba0a-f23a-4f8a-697e3cad1fae@uclouvain.be>
Subject: Re: [PATCH] ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC
 8200"
References: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>
In-Reply-To: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>

--8fxamJTnWr8Sew6PH9UhrPcGODDHhScqR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08/28/2017 07:20 PM, Ahmed Abdelsalam wrote:
> This patch fixes the get_srh(), so it gets the segment routing header
> regardless of its position in the chain of the extension headers in IPv=
6
> packet, and makes sure that the IPv6 routing extension header is of
> Type 4.

Ahmed,

You need to initialize srhoff to 0, otherwise ipv6_find_hdr() will crash
the kernel by dereferencing an uninitialized pointer.

Please test your patches before submitting them.

Furthermore, your pskb_may_pull() check should happen right after the
call to ipv6_find_hdr, with srhoff + sizeof(*srh) as argument. Once you
have checked the SRH type, you can then do another pskb_may_pull with
srhoff + len.

David


--8fxamJTnWr8Sew6PH9UhrPcGODDHhScqR--

--EbACec4fA0GumBpAq0Vm54UgSWm6IBBMx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWaRlbwAKCRCNvOfruxno
A6hVAJ9kbnjgNDjYKS0Gp9/UfszSsZqzQgCfSXBbOSQcT5xKYQRqCcPUjlzQiHk=
=cR9q
-----END PGP SIGNATURE-----

--EbACec4fA0GumBpAq0Vm54UgSWm6IBBMx--
