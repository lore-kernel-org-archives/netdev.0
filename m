From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP/UDP encapsulation
Date: Thu, 08 Apr 2010 09:58:54 +0200
Message-ID: <1270713534.2215.10.camel@edumazet-laptop>
References: <20100408074247.GA19798@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, marco bonola <marco.bonola@gmail.com>,
	"ZioPRoTo (Saverio Proto)" <zioproto@gmail.com>,
	Behling Mario <mb@mariobehling.de>,
	"L. Aaron Kaplan" <aaron@lo-res.org>
To: "Gustavo F. Padovan" <gustavo@padovan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:54542 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab0DHH67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 03:58:59 -0400
Received: by bwz1 with SMTP id 1so1541604bwz.21
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 00:58:57 -0700 (PDT)
In-Reply-To: <20100408074247.GA19798@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 04:42 -0300, Gustavo F. Padovan a =C3=A9c=
rit :
> Hi,
>=20
> I'm looking for some advice on that work. The Freifunk organization i=
s
> planning work on the IP/UDP encapsulation kernel module as a GSoC
> project. The idea is to create a IP-in-UDP tunnel like we do for
> IP-in-IP or IP-in-GRE tunnels. The only way to do that today is to us=
e
> some VPN software.
>=20
> The module will export its virtual interface through sockets and will
> have support for the standard syscalls like the others encapsulation
> modules.
>=20
> It will improve the performance of mesh networks that will we be able
> to use IP-in-UDP rather than IP-in-IP. So, instead of push all data t=
o
> local gateway into the mesh all the data can be tunneled to a faster
> server and from there to the Internet. With all the data exiting with
> the same IP address (the fast server IP). That will improve bandwidth=
,
> especially for upload.
>=20
> Is such module acceptable for merge into the Linux Kernel?
>=20
> Any comments or suggestions to the module architecture and
> implementation? If you want more information about the module I can
> provide that.
>=20
> Regards,
>=20

My suggestion would be to take a look at l2tp, which uses udp
encapsulation.

net-next-2.6

net/l2tp/l2tp_core.c:1108:		(udp_sk(sk))->encap_type =3D 0;
net/l2tp/l2tp_core.c:1304:	enum l2tp_encap_type encap =3D L2TP_ENCAPTYP=
E_UDP;
net/l2tp/l2tp_core.c:1383:		udp_sk(sk)->encap_type =3D UDP_ENCAP_L2TPIN=
UDP;
net/l2tp/l2tp_core.h:148:	enum l2tp_encap_type	encap;
net/l2tp/l2tp_core.h:171:	enum l2tp_encap_type	encap;
net/ipv4/udp.c:1299:	if (up->encap_type) {
net/ipv4/udp.c:1660:			up->encap_type =3D val;
net/ipv4/udp.c:1747:		val =3D up->encap_type;
include/linux/l2tp.h:81:	L2TP_ATTR_ENCAP_TYPE,		/* u16, enum l2tp_encap=
_type */
include/linux/l2tp.h:146:enum l2tp_encap_type {
include/linux/udp.h:63:  	__u16		 encap_type;	/* Is this an Encapsulati=
on socket? */


