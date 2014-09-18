From: Joe M <joe9mail@gmail.com>
Subject: Re: Figuring out how vti works
Date: Thu, 18 Sep 2014 00:08:07 -0500
Message-ID: <20140918050807.GA10599@master>
References: <20140915142043.GA22070@master>
 <20140917052811.GT6390@secunet.com>
 <CAHjjW16qdT6RWuJaUd1c6k39RgcPtfsyF=V-dVowW_2UwhF_dw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33086 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaIRFIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 01:08:09 -0400
Received: by mail-oi0-f51.google.com with SMTP id x69so262079oia.24
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 22:08:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHjjW16qdT6RWuJaUd1c6k39RgcPtfsyF=V-dVowW_2UwhF_dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Steffen,

Checking further with printk's, I can see

vti_tunnel_init being called for both ip_vti0 and vtil tunnels. But,
when vti_tunnel_xmit is called, it is called with ip_vti0 tunnel and
not the vtil tunnel. I am not sure if I am setting the route wrong. I
saw a comment that vti_tunnel_xmit is called by dev_queue_xmit
function. I could not figure out what dev_queue_xmit does though.=20

master# echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
1
master# modprobe ip_vti
master# ipsec start
Starting strongSwan 5.2.0 IPsec [starter]...
master# ip tunnel add vtil mode vti local 192.168.0.11 remote 192.168.1.232=
 ikey 1 okey 1
master# ip link set vtil up
master# sleep 10
master# ip route add 192.168.1.0/24 dev vtil
master# ip route list
default via 192.168.0.1 dev enp4s0  metric 202
127.0.0.0/8 dev lo  scope host
192.168.0.0/24 dev enp4s0  proto kernel  scope link  src 192.168.0.11  metr=
ic 202
192.168.1.0/24 dev vtil  scope link

ip link list
=2E
=2E
=2E
13: ip_vti0@NONE: <NOARP,UP,LOWER_UP> mtu 1428 qdisc noqueue state UNKNOWN =
mode DEFAULT group default
    link/ipip 0.0.0.0 brd 0.0.0.0
14: vtil@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1428 qdisc noqueue state=
 UNKNOWN mode DEFAULT group default
    link/ipip 192.168.0.11 peer 192.168.1.232
master# ip tunnel list
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
vtil: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit  key 1

Just wanted to check if you have any suggestions to go about debugging
this.

Thanks
Joe


--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUGmi3AAoJENvmPC7PRKkILsYQAIsgshOZp9s48hSQwLxqj812
8brtXhBRyMunWnFJUvx4ifmfLLTVpPfsTTpI0Z33B+bzhrPep/H37nc5lKpW0w+C
RJRR9+NA+uIrpIKGE1u6Gg8dhbhl7v6Dw/GFj4+cfK1JnjckloCjbRnFW1k3J44b
M/0qvoYjBF87SQGD/4zdOYtTD9sE6v43IbZixE0DOmqH+yLTu9cIY/DXEqv1lNaL
PQK1AIm/exIug2lv+6KhBwM60rDp4JoWNp2JLX5f3/db59r6cdaSVnk1A7aDvlp5
FYUCM80B38YhH3ULya93N2cw4jhJmPbjU7UnD4Te85KtbxALeSwVWkc9/IswI/Q2
IQ7oW5nCWi7l4ZCMgFmOumvQ99p4OlT3l/I2rV/1O61EV65xSk8e3fv92iQm8QcF
thiq7WoxNS31AdOpiFKVLi7Z6ocUrL1aL3+Tup0A9Oa4FvWmbjLqf9KQnPe4+7lh
M0m+WQKCvB6NWExWHkpNPlF9jcocT/0Gl4KK8t2yUQrdpyvUczc68TAlAQ/veBb6
7QdJeefztIwfC+7UPahJ9VBg+UYa3hPCLP/x6qAYMv4CE2NwOPs1u1XGwBoa2Euy
BuMZeN9SgPvyxqWrhVjdjss/kRt8jN9/ZbyI4ELv56Q6cCsagwzcds9oh8mdeb43
6+YOxKR/VMoEo92+4csD
=13cj
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--
