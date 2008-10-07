From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 16/16] Add documentation
Date: Tue, 07 Oct 2008 09:01:10 +0200
Message-ID: <1223362870.8909.11.camel@nessa.odu>
References: <20081001142431.4893.48078.stgit@este>
 <20081001142431.4893.5367.stgit@este>
 <alpine.LNX.1.10.0810030949300.3893@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <alpine.LNX.1.10.0810030949300.3893@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 2008-10-03 at 10:01 -0400, Jan Engelhardt wrote:
> On Wednesday 2008-10-01 10:24, KOVACS Krisztian wrote:
>=20
> >+Transparent proxy support
> >+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> >+
> >+This feature adds Linux 2.2-like transparent proxy support to curre=
nt kernels.
> >+To use it, enable NETFILTER_TPROXY, the socket match and the TPROXY=
 target in
> >+your kernel config. You will need policy routing too, so be sure to=
 enable that
> >+as well.
>=20
> To use server-side transparent proxying (i.e. using a foreign address
> when sending out packets), only tproxy_core is needed.
>=20
> >+fd =3D socket(AF_INET, SOCK_STREAM, 0);
>=20
> You want to be using IPPROTO_TCP here, as I doubt there is a guarante=
e
> that 0 will never choose SCTP.
>=20
> >+int value =3D 1;
>=20
> Const is good:
> 	static const unsigned int value =3D 1;
>=20
> >+setsockopt(fd, SOL_IP, IP_TRANSPARENT, &value, sizeof(value));
> >+/* - 8< -*/
> >+name.sin_family =3D AF_INET;
> >+name.sin_port =3D htons(0xCAFE);
> >+name.sin_addr.s_addr =3D htonl(0xDEADBEEF);
>=20
> Replace last one by
> 	inet_pton(PF_INET, "192.0.2.37", &name.sin_addr);
>=20
> (Hacking anything inside sin_addr is, strictly speaking, breaking the
> =E2=80=9Cencapsulation=E2=80=9D, as far as that =E2=80=9Cexists=E2=80=
=9D in C.)
>=20
> >+bind(fd, &name, sizeof(name));
>=20
> You will need
>=20
> 	bind(fd, (const void *)&name, sizeof(name));
>=20
> to avoid a compiler warning ;-)

Jan, while you're right I think the point of the aim of the example is
to show you that you only need to set the IP_TRANSPARENT flag before
being able to bind to a non-local address.

I'm not opposed to the changes, though, so could you please send a patc=
h
on top of Dave's current net-next tree? Thanks.

>=20
> >+2. Redirecting traffic
> >+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >+
> >+Transparent proxying often involves "intercepting" traffic on a rou=
ter. This is
> >+usually done with the iptables REDIRECT target, however, there are =
serious
> >+limitations of that method. One of the major issues is that it actu=
ally
> >+modifies the packets to change the destination address -- which mig=
ht not be
> >+acceptable in certain situations. (Think of proxying UDP for exampl=
e: you won't
> >+be able to find out the original destination address. Even in case =
of TCP
> >+getting the original destination address is racy.)
>=20
> IIRC, you _can_ find out, though I agree it's rather a hack (with=20
> tproxy, you can just use the address as received via recvmsg):
>=20
> 	getsockopt(fd, SOL_IP, SO_ORIGINAL_DST, &sockaddr, &sizeptr);

This is true only if you have connection tracking loaded while the new
tproxy can be used without conntrack.

--=20
KOVACS Krisztian

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
