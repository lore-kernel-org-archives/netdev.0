From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Sat, 29 Jul 2006 15:12:44 +0100
Message-ID: <20060729141244.GJ8334@innerghost.net>
References: <44CB2914.9010803@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hk6Zb6cduJ+I0Tmj"
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:6064 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S932156AbWG2OMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 10:12:45 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <44CB2914.9010803@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hk6Zb6cduJ+I0Tmj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

   First of all and to be fair let me introduce my bias -- i'm also
 developing a mobility framework, which although not MIPv6-specific,
 does support it (we'll be running a large set of tests during the
 following month, hopefully culminating in an initial public release in
 september). In general, i'm all for integrating mobility required
 code into the kernel, however i have some comments regarding your
 approaches. Due to the large amount of small patches which are
 difficult to comment (please send an e-mail with a list of them next
 time please) i'll just leave a couple of high level comments:

   - In general, lot's of places in the IPv6 stack don't take the source
     address into consideration and generically only use destination as
     key, i think this is a major setback that should be approached
     individually.

   - I don't like having the individual MIPv6-specific messages checking
     in the kernel because feature-wise this is not scalable. Only
     data-path specific processing should be done in the kernel IMO (RT2
     hdr processing, HOA DSTopt processing with address swapping, etc)
     Introducing new mobility header message type would involve modify-
     ing the kernel when there would be no other reason to do so (you
     would then need NEMO-specific code in the kernel, FMIPv6-specific
     code, etc). Taking the error reporting as an example, what i would
     prefer would be a way of either signaling the kernel ICMPv6
     component to send ParamProb or other types of errors (difficult to
     support), or instead introducing a new datagram control message
     that would enable the control application to retrieve the original
     network headers (although possibly modified) and send the ICMPv6
     message itself (which was my choice).

   - Maybe others disagree, but i don't like having a "Route
     optimization" mode in XFRM. From my POV, "Route optimization" is
     one kind of transformation specific to MIPv6. Other protocols
     require other kind of transformations. I think XFRM should be
     instead extended to support generic transformations, where the
     Mobile IPv6-specific one would implement a RO transform in order to
     support it's binding cache. Also, these new modes are not
     "advanced" but instead "Mobile IPv6 specific".

   Best regards,

      Hugo

On Sat, Jul 29, 2006 at 06:23:32PM +0900, Masahide NAKAMURA wrote:
> Hello,
>=20
> Let me introduce Mobile IPv6(RFC3775) patch and its outline.
>=20
> We USAGI project and HUT Go/Core project have developed
> for Mobile IPv6(MIPv6) stack on 2.6 tree as MIPL2 for several years.
> Our aim is to make kernel patch smaller (than MIPL1 which is for
> 2.4 kernel).
>=20
> We find out we have 4 categories for the patch:
>=20
> 1. IPv6 policy routing
> 2. IPsec MIGRATE
> 3. Advanced XFRM for Correspondent Node(CN)
> 4. MISC
>=20
> 3, 4 are MIPv6 specific feature but 1, 2 are not.
> It can be discussed in parallel about 1, 2, 3 because they
> don't depend on others.
>=20
>=20
> 1. IPv6 policy routing
> Thomas and Yoshifuji have already started to discuss and work for it.
> This is required by Mobile Node(MN) and used by Home Agent(HA).
>=20
> 2. IPsec MIGRATE
> This is an interface to update IPsec end-point address of SAD/SPD.
> (there is an IETF draft: draft-sugimoto-mip6-pfkey-migrate-XX)
> This is required by MN and HA to use IPsec tunnel.
>=20
> 3. Advanced XFRM for CN
> "Route optimization" defined MIPv6 specification
> is designed as XFRM extension. IPv6 extension headers
> handling is included, too.
> This feature is required by all MIPv6 nodes(CN, MN, HA) then it can
> be said MIPv6 platform.
>=20
> 4. MISC
> This is a set of small patches but works with the above categories
> since they are finally confirmed as the MIPv6 node behavior;
> e.g. home addressing for MN, proxy forwarding for HA.
>=20
>=20
> At first I'll send patches about category "3" very soon, just for review.
> Can you check them?
>=20
> Thanks,
>=20
> --=20
> Masahide NAKAMURA
>=20
>=20
>=20
>=20
>=20
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--hk6Zb6cduJ+I0Tmj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEy2zb7asb/itUNKwRAt6IAJ9V755Ftae8kT+4suBcFiRuPD3NSwCfS0hb
7wbcY+vTW+cbwRQusPHqk0I=
=fw8W
-----END PGP SIGNATURE-----

--hk6Zb6cduJ+I0Tmj--
