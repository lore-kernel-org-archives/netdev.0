From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel
 support
Date: Wed, 23 Nov 2016 10:28:29 +0100
Message-ID: <5835613D.8070104@uclouvain.be>
References: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com> <5835466B.6080405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="76qpQvoDV1wGsd9f8WkrkDrRwbr0ETn1F"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59044 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933431AbcKWJ2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 04:28:41 -0500
In-Reply-To: <5835466B.6080405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--76qpQvoDV1wGsd9f8WkrkDrRwbr0ETn1F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/23/2016 08:34 AM, Roopa Prabhu wrote:
> I can't seem to reproduce the problem you are seeing. still trying..
> I don't have CONFIG_LWTUNNEL set nor any of the other SEG6 configs.
> My CONFIG_IPV6 is on and compiled as a module. I have also tried disabl=
ing it.
> If you can send me the config, I can try again. Looking back at the pat=
ches,
> I do see a few things below ..but they may not fix your problem directl=
y.
>=20
> Though I had none of the ipv6 segment routing configs turned on,
> I do see the "Segment Routing with IPv6" msg at bootup.
> Was looking at david's patches again, and a few things (I had missed se=
eing the last version):
>=20
> In my review comment I was hinting at CONFIG_IPV6_SEG6 to cover all of =
ipv6 segment routing,
> including the lwtunnel bits.
>=20
> something like below:
>=20
> config IPV6_SEG6
>         bool "IPv6: Segment Routing Header encapsulation support"
>         depends on LWTUNNEL && IPV6
>=20
> DavidL, do you see a problem doing it this way ?. with this 'seg6.o' wi=
ll be part of CONFIG_IPV6_SEG6 and not
> get initialized unless it is enabled..which seems like the right thing =
to do.

Can't reproduce the bug either, with CONFIG_IPV6=3Dy, LWTUNNEL=3Dn and al=
l
SEG6 disabled. Alexei, your .config and dmesg log could help.

Roopa, the reason why seg6.o is compiled by default is that it provides
an interface to control HMAC structures, and that HMAC does not depends
on lwtunnels and can be used in the extension header processing (which
is compiled by default). I could indeed add another option to
conditionnally compile seg6.o if HMAC is enabled etc, and I actually had
something like that in the very first versions of the patch, but I
received comments that too much options is not a good thing (and I agree
with that).

Anyway, I do not see how seg6.o could possibly generate such a bug given
the only thing it does is register a genetlink family and pernet ops
that allocate/deallocate a struct. Genetlink is compiled by default with
NET and register_pernet_subsys does not fail even when namespaces
support is disabled.

David


--76qpQvoDV1wGsd9f8WkrkDrRwbr0ETn1F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlg1YT4ACgkQjbzn67sZ6APjWACfXEq9xlCNs0ChAukg8mmoSwOI
cccAn2xZGoJZhO0yzS/EznhebDMAGLLY
=iFXA
-----END PGP SIGNATURE-----

--76qpQvoDV1wGsd9f8WkrkDrRwbr0ETn1F--
