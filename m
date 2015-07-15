From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: next-20150714 - busted IPv6 source address selection...
Date: Wed, 15 Jul 2015 02:13:00 -0400
Message-ID: <3528.1436940780@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1436940780_3381P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hideaki.yoshifuji@miraclelinux.com, ek@google.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1436940780_3381P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

next-20150714 w/ one ethernet commit reverted. -0706 w/ same revert works=
.

=22ip addr show=22 for the wireless says:

5: wlp3s0b1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel st=
ate UP group default qlen 1000
    link/ether bc:85:56:1f:4f:6d brd ff:ff:ff:ff:ff:ff
    inet 172.30.42.75/27 brd 172.30.42.95 scope global dynamic wlp3s0b1
       valid_lft 80952sec preferred_lft 80952sec
    inet6 2601:5c0:c100:9243:449b:a30:2f54:5b/64 scope global temporary d=
ynamic=20
       valid_lft 7181sec preferred_lft 1781sec
    inet6 2601:5c0:c100:9243:be85:56ff:fe1f:4f6d/64 scope global mngtmpad=
dr dynamic=20
       valid_lft 7181sec preferred_lft 1781sec
    inet6 fe80::be85:56ff:fe1f:4f6d/64 scope link=20
       valid_lft forever preferred_lft forever

but outbound packets have a bogus source address:

23:01:52.938986 IP6 a835::100:0:200:0.41360 > 2001:500:19::1.domain: 4183=
5% =5B1au=5D AAAA? c0.info.afilias-nst.info. (53)
23:05:54.131991 IP6 a835::100:0:200:0 > 2001:468:c80:2105:211:43ff:feda:d=
769: ICMP6, echo request, seq 56, length 64

Interestingly enough, link-local addresses manage to get it wrong
in another fashion:

23:02:52.806011 IP6 fe80::120d:7fff:fe64:ca0b.60625 > ff02::c.ssdp: UDP, =
length 411

I suspected this commit mostly because it's the only one that seems to
touch source selection recebntly...

commit 9131f3de24db4dc12199aede7d931e6703e97f3b
Author: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.y=
oshifuji=40miraclelinux.com>
Date:   Fri Jul 10 16:58:31 2015 +0900

    ipv6: Do not iterate over all interfaces when finding source address =
on specific interface.

Reverting this commit make things work again.


--==_Exmh_1436940780_3381P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVaX57AdmEQWDXROgAQIHDRAAs0g6G+3N7iQ1hV+iDNAO+M/KWL3mx43Q
91HgRwBlHtFMwOl7hUGAR22toO4eTMr+dxVr4Z6Juj4IasrRJUTqKJ9AvFKslbtc
3YlVhn1+0a3aWH2jORnfu+Ja8g6DNCTBCp4RavzPUHtNGkv0ZYouBiMa8oDnnrIl
OqzApzQnBMnQwKuMeaR7s7oR+7WzY0E5I43DOlAH845Hs9N5oPHBWTqEWZ7CrK/X
M6nBObsmkoPo1S8l6CrKIk7kT0bEa/d2H3eT4Q1NKNai5hcSd/wEC3AVl67TB3Yq
6w2Dc5HJwtCMCehnVaC327p+ikCTW2BAlQfot9FAUuhIaEiFts18tiqDQvh6q7By
E2cSQAhLnmhBmlc3EKO05ukBccJ0QggDV3sEMMtyLAP3JZmd1d1N/F7VUJrGqcf/
V7d5y+TkJnfcn9G90ovygV7l6KZtx+wKlaFV7L7mNFKy1cvu2MkHsW/Ao7D3wfPO
EL0p/doTYDH/X45q+ChGzW5GkoSFoQf5AKFN/idWwqb5gLfzTTXhvhetFrzuk1Ym
q8/5jTS2PcQpbbX2TEgeZmQ8kRGgXn1qDrRoAyPNbW8WpGUdS+Vzb4JW1x63UnO3
6oM2lKVU6cGMmKF2NovOx7O/91M8kLC55/xjRB821klJDYJs9ALcimz3PLMINFDh
gcM7sjenm2c=
=Pbbo
-----END PGP SIGNATURE-----

--==_Exmh_1436940780_3381P--
