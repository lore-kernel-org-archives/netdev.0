From: Harald Welte <laforge@netfilter.org>
Subject: 2.6.8.1 IPv6 Routing Problem
Date: Sat, 18 Sep 2004 01:08:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917230803.GJ2678@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8KmZJhJMEENkOiL3"
Cc: usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--8KmZJhJMEENkOiL3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I'm experiencing some strange problems on a 2.6.8.1 vanilla kernel.  I
tried to reproduce it with a minimal system:


1) address configuration (just loopback, link-local and one global)

/proc/sys/net/ipv6/conf # ip -6 addr show
1: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qlen 1000
    inet6 3ffe:400:900:3001::2/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::20d:b9ff:fe00:a88/64 scope link=20
       valid_lft forever preferred_lft forever
3: lo: <LOOPBACK,UP> mtu 16436=20
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever

2) routing table:

/proc/sys/net/ipv6/conf # ip -6 route show
3ffe:400:900:3001::/64 dev eth0  metric 256=20
fe80::/64 dev eth0  metric 256=20
ff00::/8 dev eth0  metric 256=20
default dev eth0  metric 256=20
unreachable default dev lo  metric -1  error -101

3) ping to localhost:

(intermixed with a 'ip6tables -A OUTPUT -j LOG' and '-A INPUT -j LOG'
rules for diagnostics).

/proc/sys/net/ipv6/conf # ping6 ::1
PING ::1 (::1): ou IN=3D OUT=3Dlo 56 data bytes
SRC=3D0000:0000:0000:0000:0000:0000:0000:0001 DST=3D0000:0000:0000:0000:000=
0:0000:0000:0001 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=3D0 PROTO=3DICMPv6 =
TYPE=3D128 CODE=3D0 ID=3D27911 SEQ=3D0=20
in IN=3Dlo OUT=3D MAC=3D00:00:00:00:00:00:00:00:00:00:00:00:86:dd SRC=3D000=
0:0000:0000:0000:0000:0000:0000:0001 DST=3D0000:0000:0000:0000:0000:0000:00=
00:0001 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=3D0 PROTO=3DICMPv6 TYPE=3D12=
8 CODE=3D0 ID=3D27911 SEQ=3D0=20
ou IN=3D OUT=3Dlo SRC=3D0000:0000:0000:0000:0000:0000:0000:0001 DST=3D0000:=
0000:0000:0000:0000:0000:0000:0001 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D129 CODE=3D0 ID=3D27911 SEQ=3D0=20
in IN=3Dlo OUT=3D MAC=3D00:00:00:00:00:00:00:00:00:00:00:00:86:dd SRC=3D000=
0:0000:0000:0000:0000:0000:0000:0001 DST=3D0000:0000:0000:0000:0000:0000:00=
00:0001 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=3D0 PROTO=3DICMPv6 TYPE=3D12=
9 CODE=3D0 ID=3D27911 SEQ=3D0=20
64 bytes from ::1: icmp6_seq=3D0 ttl=3D64 time=3D246.2 ms               =20


4) ping to global address

/proc/sys/net/ipv6/conf # ping6 3ffe:400:900:3001::2
PING 3ffe:400:90ou IN=3D OUT=3Deth0 0:3001::2 (3ffe:SRC=3D3ffe:0400:0900:30=
01:0000:0000:0000:0002 400:900:3001::2)DST=3D3ffe:0400:0900:3001:0000:0000:=
0000:0002 : 56 datLEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=3D0=20
                                   PROTO=3DICMPv6 TYPE=3D128 CODE=3D0 ID=3D=
28167 SEQ=3D0=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3Dff0=
2:0000:0000:0000:0000:0001:ff00:0002 LEN=3D72 TC=3D0 HOPLIMIT=3D255 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D135 CODE=3D0=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3Dff0=
2:0000:0000:0000:0000:0001:ff00:0002 LEN=3D72 TC=3D0 HOPLIMIT=3D255 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D135 CODE=3D0=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3D3ff=
e:0400:0900:3001:0000:0000:0000:0002 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D128 CODE=3D0 ID=3D28167 SEQ=3D256=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3Dff0=
2:0000:0000:0000:0000:0001:ff00:0002 LEN=3D72 TC=3D0 HOPLIMIT=3D255 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D135 CODE=3D0=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3D3ff=
e:0400:0900:3001:0000:0000:0000:0002 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D128 CODE=3D0 ID=3D28167 SEQ=3D512=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3D3ff=
e:0400:0900:3001:0000:0000:0000:0002 LEN=3D152 TC=3D0 HOPLIMIT=3D64 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D1 CODE=3D3 [SRC=3D3ffe:0400:0900:3001:0000:0000:=
0000:0002 DST=3D3ffe:0400:0900:3001:0000:0000:0000:0002 LEN=3D104 TC=3D0 HO=
PLIMIT=3D64 FLOWLBL=3D0 PROTO=3DICMPv6 TYPE=3D128 CODE=3D0 ID=3D28167 SEQ=
=3D0 ]=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3Dff0=
2:0000:0000:0000:0000:0001:ff00:0002 LEN=3D72 TC=3D0 HOPLIMIT=3D255 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D135 CODE=3D0=20
ou IN=3D OUT=3Deth0 SRC=3D3ffe:0400:0900:3001:0000:0000:0000:0002 DST=3D3ff=
e:0400:0900:3001:0000:0000:0000:0002 LEN=3D104 TC=3D0 HOPLIMIT=3D64 FLOWLBL=
=3D0 PROTO=3DICMPv6 TYPE=3D128 CODE=3D0 ID=3D28167 SEQ=3D768=20
                        =20
--- 3ffe:400:900:3001::2 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss

Apparently the node tries to do neighbour solicitation on itself, and
then even sends an ICMPv6 destination unreachable to itself, all over
the ethernet device ?!?

Can anybody please explain what's going on?

Thanks!

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--8KmZJhJMEENkOiL3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBS25TXaXGVTD0i/8RAuo9AJ9BK1HlGkKdgXgvVF1mzSIZdOTvHACgmjJK
XVZPvxaFLX/Wt8vmnInkDTo=
=3jUj
-----END PGP SIGNATURE-----

--8KmZJhJMEENkOiL3--
