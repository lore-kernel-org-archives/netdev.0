From: Christian Hesse <mail@eworm.de>
Subject: Re: [PATCH v3 1/1] ip-link: add switch to show human readable
 output
Date: Fri, 31 Oct 2014 11:17:53 +0100
Message-ID: <20141031111753.2b524ebb@leda.localdomain>
References: <20141029224738.263e27bd@urahara>
	<1414660599-25707-1-git-send-email-mail@eworm.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/N8GVLveIvPulifKcLoopvkc"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:36696 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380AbaJaK0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 06:26:07 -0400
In-Reply-To: <1414660599-25707-1-git-send-email-mail@eworm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/N8GVLveIvPulifKcLoopvkc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger <stephen@networkplumber.org> on Wed, 2014/10/29 22:47:
> I like the idea as a concept

Great! ;)

> but there are two issues:
>   1. The IEC suffix is a rarely used thing and is non-standard
>      for communications where K =3D 1000 M =3D 1000000 etc.
>      Please just use standard suffices

Removed the suffix in patch v3. Not sure if it is correct, though. I do use=
 a
base of 2, so K =3D 1024, M =3D 1048576, ...

This is what ifconfig behaves as well. Output should give the exact same
numbers (except the suffix):

# ip -s -h link list en
3: en: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
mode DEFAULT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    26.3M      59.2K    0       68      0       0
    TX: bytes  packets  errors  dropped carrier collsns
    37.0M      67.6K    0       0       0       0
# ifconfig en=20
en: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet XX.XX.XX.XX  netmask 255.255.255.0  broadcast XX.XX.XX.255
        ether 00:de:ad:be:ee:ef  txqueuelen 1000  (Ethernet)
        RX packets 60677  bytes 27671339 (26.3 MiB)
        RX errors 0  dropped 68  overruns 0  frame 0
        TX packets 69350  bytes 38874609 (37.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

>   2. Don't double print the data, if the user asks for human
>      format, only show the human format.

Fixed.

Hopefully I got the line breaks right. How to check print_link_stats32()?
Even von i686 ip calls print_link_stats64() on my systems.

I did some minor changes to the error stats column alignment. Is that ok? S=
ee
the difference of before and after:

# ip -s -s link list en    # before
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state =
UP
mode DEFAULT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff=20
    RX: bytes  packets  errors  dropped overrun mcast  =20
    144544239  100441   0       0       0       1     =20
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    808343     9630     0       0       0       0     =20
    TX errors: aborted fifo    window  heartbeat transns
               0        0       0       0        2     =20
# ip -s -s link list en    # after
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state =
UP
mode DEFAULT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    87432187   60642    0       0       0       1
    RX errors: length   crc     frame   fifo    missed
               0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns=20
    450437     5793     0       0       0       0     =20
    TX errors: aborted  fifo   window heartbeat transns
               0        0       0       0       2     =20
--=20
Best regards,
Christian Hesse

--Sig_/N8GVLveIvPulifKcLoopvkc
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUU2HWAAoJEFTtyRYJvJGD50UP/3wrDRDmaFA1H6dNzpf1r2mW
m00V6WIxvzbb1A2AXHPkm/nZH6/pZS/J2JYTj+jN4uhtr3Aezd3dDoj0N9g+4Lyb
lHyi9KU3EMudXJuMbsRzgsRVPrtxm070VdtB9g6PPifPkgVtjFZTkO6hQP/MlVkY
VjScf3IeNBh0mQ30g0kme8QRTQwIgzEiT+IE7StQS8t8+t4W+qweNFRb0v77OPbQ
5TtI2NLQaoz5OZGFONHuVQ4E5EqunN4PSHs8KmwU0E4EskXzjeAzvoAxk5HdzXlk
2EDJXUeEex/xUAsUT/yiCJfZ5/OaBILkpVLrAItUWaLfXj/MxOufuXwEy6wc3DOC
VICPRta3RhOaLpGtJIaFKXfbee8KeBkkrh+2edSl1QYiZna8+U3e2Hzf4IAKFmT8
EDqIrxpYK4/5hRKgYIt7UYKFRFWIbEt4UWm4xxaoAbxiHCID0g1mllLfd7KBfCkC
toxWATwAMUFMhSjdI0IuwU1DoVszuqd7Sygr8FbdSSeMSk3yaDm4DJovLQZxhNEp
YuT54Tk1h9MDzsRdMQPOozRNC1dRpkIiRAQUktS2rW3n1VQbl2d140PZ4nCpZE8b
fDyOSwaYJ2DOmeD6guLlHvaxUGhlctubAq4UhnCzysuRabTHYId3lGVjeMqpPZ/I
8HxWPydi8HT0yumi6aNS
=gQmS
-----END PGP SIGNATURE-----

--Sig_/N8GVLveIvPulifKcLoopvkc--
