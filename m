From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: pktgen with vlan packets
Date: Fri, 20 May 2011 17:20:37 +0200
Message-ID: <1305904837.3173.20.camel@edumazet-laptop>
References: <BANLkTinybQHjqXe-0SOU4wHTJg0M=QX=ow@mail.gmail.com>
	 <BANLkTinBGkApfasGywg888wDXZBYPOpQDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Lynch, Jonathan" <jonathan.lynch@thenowfactory.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57921 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab1ETPUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 11:20:41 -0400
Received: by wwa36 with SMTP id 36so4134506wwa.1
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 08:20:40 -0700 (PDT)
In-Reply-To: <BANLkTinBGkApfasGywg888wDXZBYPOpQDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 mai 2011 =C3=A0 16:03 +0100, Lynch, Jonathan a =C3=A9cri=
t :
> Hi,
>=20
> Im running 2.6.35 kernel with an Intel 82599 NIC.
> I want to send packets using pktgen via a number of vlan interfaces (=
1
> physical interface) created via vconfig but I get an OOPs when I try
> and send via the vlan interface.  See attached log file for the oops.
> Im not using the pgset "vlan_id 77" params because I want to send
> packets with more than 1 VLAN tag to one interface. (If it was
> possible to send packets with different vlan tags over the one
> interface with pktgen I would use it)
>=20
> my config is as follows:
>   ifconfig eth4 up
>   modprobe 8021q
>   vconfig add eth4 256
>   ifconfig eth4.256 up
>=20
> My pktgen config is the exact same as
> ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/=
pktgen.conf-1-1
> except that instead of eth1, I have eth4.256.
>=20
> Any ideas as to how I can send packets with multiple VLAN tags over
> the same interface with pktgen?

I am afraid you cant yet.

About the crash, you can either :

1) delete qdisc on eth4

ifconfig eth4 txqueuelen 0
tc qdisc add dev eth0 root sfq
tc qdisc del dev eth0 root

2) use clone_skb 0 only

(Or else, same skb can be queued several time on eth4 qdisc) -> crash



