From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: Re: net/ipv6/exthdrs.c
Date: Tue, 18 Jun 2002 15:50:21 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020618155021.A12974@sch.bme.hu>
References: <20020618135149.A24751@sch.bme.hu> <Pine.LNX.4.44.0206181458340.26140-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0206181458340.26140-100000@netcore.fi>
List-Id: netdev.vger.kernel.org

Pekka Savola ........................................ (2002. j=FAnius 18.=
)

 Hi!

> > Is there any plan to add the ESP header to the ipv6_ext_hdr() functio=
n (as a
> > known header)?
> > (It requires changes in this file and in the icmp.c at the first roun=
d.)
> Quickly looking at it, I don't know if adding it would help any (on the=
=20
> countrary).
At the firewall side the ESP is a known extension header. The ESP contain=
s
some field which can be parsed in a strict firewall rule.
When the extension headers and the main header parsed by the Netfilter, t=
he
upper level protocol should be passed to the next level for future parsin=
g.
The implementation follows the standard where the ESP is one of the exten=
sion
headers.
BTW, the Netfilter code can be changed to this behaviour. (Minor changes =
in
some file and a major change in the ESP match.)

The ipv6_ext_hdr() could be exported? It would be usefull at the Netfilte=
r
side.
(And when we are there: the ipv6_skip_exthdr() should be exported, too.)

> The code seems to be used mainly to skip over extension headers
> (forbidden, strictly speaking) when generating ICMP messages; in the ca=
se=20
> of ESP, the rest of the payload should be encrypted so adding it to the=
=20
> list would probably not change anything?
At first look in the ipv6_skip_exthdr() in the parser loop:
-                if (nexthdr =3D=3D NEXTHDR_NONE)
+                if ( (nexthdr =3D=3D NEXTHDR_NONE) || (nexthdr =3D=3D NE=
XTHDR_ESP) )
But after this change the ICMPv6 reply won't contain the ESP ...

Regards,

	kisza

--=20
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /-----Member of the BUTE-MIS-SEARCHlab---------->
