From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP reply uses wrong source address as destinatio
Date: Tue, 01 Mar 2011 11:27:43 +0100
Message-ID: <1298975263.3284.10.camel@edumazet-laptop>
References: <AANLkTinOCp3e6tiWgesPtKYwB7Mj=Ch6Ccm1xeSFLcpD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anders Nilsson Plymoth <lml@telhoc.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64236 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756146Ab1CAK1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 05:27:47 -0500
Received: by fxm17 with SMTP id 17so4642824fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 02:27:46 -0800 (PST)
In-Reply-To: <AANLkTinOCp3e6tiWgesPtKYwB7Mj=Ch6Ccm1xeSFLcpD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 09:49 +0100, Anders Nilsson Plymoth a =C3=A9=
crit :
> Dear linux kernel enthusiasts,
>=20
> I came upon an issue where ICMP reply packets were issued towards the
> IP address of the receiving interface, rather than the source IP
> address.
> Looking at the kernel code, I saw that this is caused by the followin=
g
> line in net/ipv4/icmp.c function icmp_reply:
>=20
> daddr =3D ipc.addr =3D rt->rt_src;
>=20
> For most cases the original line of code is ok, but in some situation=
s
> doesn't arrive to the kernel from the network device, but through som=
e
> other mechanism such as a userspace application. In these cases the
> receiving device in the skb appears to be the loopback interface, not
> a physical device. icmp_reply will thus issue the reply to the
> loopback IP address, rather than the source IP address as it should.
>=20
> While googling to see if this issue have been submitted, I found this
> two posts that address the same problem:
> h**p://www.mail-archive.com/linux-kernel@vger.kernel.org/msg209746.ht=
ml
> h**p://www.mail-archive.com/linux-kernel@vger.kernel.org/msg208272.ht=
ml
> Some of the questions there are easy to answer; such as this doesn't
> affect DNAT, and if source address is not set then you can' reply
> anyway.
>=20
> As to the statement:
> "... which IP address should be used as the source
>=20
> 1. the destination address of the packet that generated the message
>=20
> or.
>=20
> 2. the IP address that the machine would use by default if the machin=
e
> were to generate a new connection to the destination."
>=20
> These may be relevant questions, but the ICMP RFC clearly states the
> answer is 1. 2. may seem relevant to multi-homing, but its not the
> role of the ICMP reply to resolve multi-homing issues.
>=20
> The following code will correct the issue.
>=20
> {
>    struct iphdr *ip =3D ip_hdr(skb);
>    daddr =3D ipc.addr =3D ip->saddr;
> }
>=20
> The only functions that use icmp_reply are icmp_echo and
> icmp_timestamp, and this change do not modify their behavior. After
> extensive testing, in regular setups and DNATed situations, I can
> verify this change works as intended.

I suspect you could respin Lepton Wu patch (from msg209746.html) on top
of net-next-2.6 and add your "Acked-by or Tested-by"

Keep in mind changelog should be very very detailed because patch was
delayed because of this.



