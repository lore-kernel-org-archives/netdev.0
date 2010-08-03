From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 15:34:42 +0100
Message-ID: <20100803143442.GW11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
 <20100803140539.GE31096@basil.fritz.box>
 <20100803141110.GT11110@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VgSl7ZiUY2n5sQix"
Cc: David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:39783 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756142Ab0HCOeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:34:44 -0400
Content-Disposition: inline
In-Reply-To: <20100803141110.GT11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VgSl7ZiUY2n5sQix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 03:11:10PM +0100, Paul LeoNerd Evans wrote:
>   switch(hdrtype)
>   {
>      case 1:
>        length =3D someconst; break;
>      case 2:
>        length =3D someotherconst; break;
>      case 3:
>        length =3D b[someoffset]; break;
>      ...
>   }

Of course, I completely forgot about finding also the offset of the
'next header' from the current header. That results in some code which,
in C, would look like:

  int hdrtype =3D b[IPv6_nexthdr];

  int x =3D size_of_IPv6_header;

  while(hdrtype !=3D hdr_wanted) {
       int len;
       switch(hdrtype) {
         case 1:
           len =3D someconst;
           hdrtype =3D someotherconst;
           break;
         case 2:
           len =3D b[x+someoffs];
           hdrtype =3D b[x+someotheroffs];
           break;
         /* other IPv6 header types here */
       }

       x +=3D len;
  }

You can't compile that idea into BPF without using a scratch memory
cell, because you can't have both 'len' and 'hdrtype' live in A at the
same time, nor can you atomically x +=3D b[x+someoffs].

In short, much much easier if the C code did this part...

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--VgSl7ZiUY2n5sQix
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWCkCvLS2TC8cBo0RAorEAKDhA+fWRkk3iGUg+iohv9Dp5YdCagCg/cW4
00aa8izcog9jyR78JvIci+M=
=l3+s
-----END PGP SIGNATURE-----

--VgSl7ZiUY2n5sQix--
