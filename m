From: Sebastian Benoit <benoit-lists@fb12.de>
Subject: network connection gets stuck with 2.5.43-bk1/mm2
Date: Fri, 18 Oct 2002 12:47:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018124717.A21622@turing.fb12.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,

i posted the message below to linux-mm yesterday, Andrew Morton told me that
it might be one of the changes in networking in -bk1.

removing these changes solved the problem:

 include/linux/ip.h        |   16=20
 include/linux/tcp.h       |    2=20
 include/linux/udp.h       |   31 -
 include/net/dst.h         |   56 --
 include/net/ip.h          |   16=20
 include/net/sock.h        |    2=20
 include/net/tcp.h         |    2=20
 include/net/udp.h         |    2=20
 net/core/dst.c            |   25 -
 net/ipv4/af_inet.c        |   17=20
 net/ipv4/icmp.c           |    4=20
 net/ipv4/ip_output.c      |  880 +++++++----------------------------------=
-----
 net/ipv4/ip_proc.c        |   74 ---
 net/ipv4/ip_sockglue.c    |    4=20
 net/ipv4/raw.c            |    7=20
 net/ipv4/tcp.c            |   49 --
 net/ipv4/tcp_ipv4.c       |    6=20
 net/ipv4/tcp_minisocks.c  |   10=20
 net/ipv4/udp.c            |  296 ---------------
 net/ipv6/tcp_ipv6.c       |    5=20
 net/netsyms.c             |    1=20

(this is the diffstat of the reverse patch)

Is this fixed already?
/B.



----------------- quote -----------------
Hi,=20

funny problem w. 2.5.43-mm2:

i'm running 2.5.43-mm2 on my workstation. Normal workload, X-windows, a few
xterms, editor, mozilla, etc. (host A)

I have a NFS/SAMBA-mount (both show the problem) to host B. Host B runs
2.4.19rc5aa1.

I can get a xterm, in which i have a ssh-connection to a third host C
'stuck' by simply cat'ing a large file from the NFS/SAMBA server to
/dev/null.

The xterm/ssh seems stuck, that is no key i press is received on the other
end, but output of the program running on host C is updated in the xterm. I
checked with tcpdump: the keypress does not generate a packet, my host only
sends ACK's on that ssh connection to host C.

The ssh-connection is not unstuck by stopping the data transfer from host B.

I checked that plain 2.5.42 and 2.5.43-mm1 do not have this problem: here my
input goes through to C. At least for small amounts of input, i did not test
anything beyond typing a few hundret chars.

recap:

 "mount /mnt/hostB"
 "ssh hostC" -> type random stuff in that connection
 at the same time do "cat /mnt/hostB/bigfile > /dev/null"
 ssh gets stuck.

hardware: PIII/600, 3c905B on 10baseT half-duplex

I'm sorry i cant do any further checks until Friday afternoon (MET).

/B.
--------------- quote ends ---------------



--=20
Sebastian Benoit <benoit-lists@fb12.de>
My mail is GnuPG signed -- Unsigned ones are bogus -- http://www.gnupg.org/
GnuPG 0x5BA22F00 2001-07-31 2999 9839 6C9E E4BF B540  C44B 4EC4 E1BE 5BA2 2=
F00

Oxymoron #633: Mutual Differences

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAj2v5rUACgkQTsThvluiLwCu1QCgi38mkGpDNKO8kw/N1BWikRsg
HR0AoIKi8Mfuf/7X27opcDoedwFOn1JN
=rhqg
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--
