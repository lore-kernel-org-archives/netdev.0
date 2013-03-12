From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: atl1c issues on 3.8.2
Date: Tue, 12 Mar 2013 16:17:53 +0100
Message-ID: <20130312161753.281681f2@milhouse>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/vF79MGy=GSpY75rN2GxNAPw"; protocol="application/pgp-signature"
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:32915 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599Ab3CLPSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 11:18:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/vF79MGy=GSpY75rN2GxNAPw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,

Starting with 3.8.x scp stalls the atl1c based interface on my Asus Eeepc 1=
011px.
iperf (for example) does not do that. But after scp stalled the interface,
iperf transfers fail, too.


0mb@milhouse:~$ iperf -c 192.168.4.2 -d
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.4.2, TCP port 5001
TCP window size: 96.0 KByte (default)
------------------------------------------------------------
[  5] local 192.168.4.1 port 41558 connected with 192.168.4.2 port 5001
[  4] local 192.168.4.1 port 5001 connected with 192.168.4.2 port 58296
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec   111 MBytes  93.0 Mbits/sec
[  4]  0.0-10.1 sec   105 MBytes  87.2 Mbits/sec
0mb@milhouse:~$ scp testfile mb.marge:
Enter passphrase for key '/home/mb/.ssh/key':=20
testfile                                                  12% 6912KB   1.8M=
B/s - stalled -^testfile                                                 12=
% 6912KB   1.6MB/s - stalled -1mb@milhouse:~$ ^C
130mb@milhouse:~$ iperf -c 192.168.4.2 -d
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
connect failed: No route to host



dmesg is spammed with these messages:


> [51069.954315] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51069.954409] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [51155.933162] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
> [51157.441946] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51276.049211] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51276.049371] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51290.233447] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51290.233641] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51305.025257] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51305.025419] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51323.305245] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51323.305405] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51338.393216] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51338.393375] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51350.739196] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
> [51353.810485] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51376.817238] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51376.817399] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>
> [51391.425209] atl1c 0000:01:00.0: irq 46 for MSI/MSI-X
> [51391.425371] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Fu=
ll Duplex>


This did not happen with earlier kernels. (But 3.7 has other issues as well=
. See my other mail)

Any ideas what's so special about scp?

--=20
Michael

--Sig_/vF79MGy=GSpY75rN2GxNAPw
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRP0chAAoJEPUyvh2QjYsOFOAP/AsGisCyVoQ2SXs5hEjZY5FB
X4BSSMnRjDEJ+reZg5nSqwVkTr4MgP7BvmnjyAEdo7vxpwILdrCMH0Nj6cfzRFC1
grOdBUueeISFlrSGajV9h/iyMZPgFDh4e2GWMw/b+S5tsjqTOamB90+akjO0HcQr
kQ1ah/WPqLbdT7GAgB74vsRzavdgThswVvyNP1O8zx4Annz+cAGF3i68ZiXhi1WP
XOA7rauSDUu0enotdwkijK4Eytoq+5lowSOL5C2yE+ZxFSm4tYgBkGYGA/O092/M
exkZ5DvSV7FdxBPLpyRJV/pBPcwC4zP1a7GQXEXXlCKbgVpTr6/0BxDd/7AmSnum
XQxu3zIejmLoW0BUZU24c9pDdaWM5eGkJUHvOdHGkQ5YnBhkpESFEIgFuc2PcTgr
d/173QWd3a6eTTJiML31n+2NJyOWt14ykCXMpWl6XVP0yavk5iKHGfq3xlLkhhVq
cWOvstFt0c56bbm/FjuZav82lIah/3M4AHKGkuHE4/WgR2UGNr4jor2UVY/6QqSb
6ZnHIY6tJC8DP5LZaun2dJNTSvWr5Sv8Bml+kwPOLczAJ/bQWuSCpOGoOKx7sJnz
Aw8CpMfaz2Py0pffYbbPQhPtTHpyWt8JxpnYVenasyT0d1c8QMS35wNdcSH/EGAH
szQYQXKKhwAUPrHyGRNW
=/4v8
-----END PGP SIGNATURE-----

--Sig_/vF79MGy=GSpY75rN2GxNAPw--
