From: Sebastian Benoit <benoit-lists@fb12.de>
Subject: network connection gets stuck with 2.5.44
Date: Mon, 21 Oct 2002 17:44:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021021174410.B8190@turing.fb12.de>
References: <20021018124717.A21622@turing.fb12.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="qcHopEYAB45HaUaB"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021018124717.A21622@turing.fb12.de>; from benoit-lists@fb12.de on Fri, Oct 18, 2002 at 12:47:17PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Still happens...

/B.

Sebastian Benoit(benoit-lists@fb12.de)@2002.10.18 12:47:17 +0000:
> Subject: Re: network connection gets stuck with 2.5.43-bk1/mm2
>=20
> Hi,
>=20
> i posted the message below to linux-mm yesterday, Andrew Morton told me t=
hat
> it might be one of the changes in networking in -bk1.
>=20
> removing these changes solved the problem:
>=20
>  include/linux/ip.h        |   16=20
>  include/linux/tcp.h       |    2=20
>  include/linux/udp.h       |   31 -
>  include/net/dst.h         |   56 --
>  include/net/ip.h          |   16=20
>  include/net/sock.h        |    2=20
>  include/net/tcp.h         |    2=20
>  include/net/udp.h         |    2=20
>  net/core/dst.c            |   25 -
>  net/ipv4/af_inet.c        |   17=20
>  net/ipv4/icmp.c           |    4=20
>  net/ipv4/ip_output.c      |  880 +++++++--------------------------------=
-------
>  net/ipv4/ip_proc.c        |   74 ---
>  net/ipv4/ip_sockglue.c    |    4=20
>  net/ipv4/raw.c            |    7=20
>  net/ipv4/tcp.c            |   49 --
>  net/ipv4/tcp_ipv4.c       |    6=20
>  net/ipv4/tcp_minisocks.c  |   10=20
>  net/ipv4/udp.c            |  296 ---------------
>  net/ipv6/tcp_ipv6.c       |    5=20
>  net/netsyms.c             |    1=20
>=20
> (this is the diffstat of the reverse patch)
>=20
> Is this fixed already?
> /B.
>=20
>=20
>=20
> ----------------- quote -----------------
> Hi,=20
>=20
> funny problem w. 2.5.43-mm2:
>=20
> i'm running 2.5.43-mm2 on my workstation. Normal workload, X-windows, a f=
ew
> xterms, editor, mozilla, etc. (host A)
>=20
> I have a NFS/SAMBA-mount (both show the problem) to host B. Host B runs
> 2.4.19rc5aa1.
>=20
> I can get a xterm, in which i have a ssh-connection to a third host C
> 'stuck' by simply cat'ing a large file from the NFS/SAMBA server to
> /dev/null.
>=20
> The xterm/ssh seems stuck, that is no key i press is received on the other
> end, but output of the program running on host C is updated in the xterm.=
 I
> checked with tcpdump: the keypress does not generate a packet, my host on=
ly
> sends ACK's on that ssh connection to host C.
>=20
> The ssh-connection is not unstuck by stopping the data transfer from host=
 B.
>=20
> I checked that plain 2.5.42 and 2.5.43-mm1 do not have this problem: here=
 my
> input goes through to C. At least for small amounts of input, i did not t=
est
> anything beyond typing a few hundret chars.
>=20
> recap:
>=20
>  "mount /mnt/hostB"
>  "ssh hostC" -> type random stuff in that connection
>  at the same time do "cat /mnt/hostB/bigfile > /dev/null"
>  ssh gets stuck.
>=20
> hardware: PIII/600, 3c905B on 10baseT half-duplex
>=20
> I'm sorry i cant do any further checks until Friday afternoon (MET).
>=20
> /B.
> --------------- quote ends ---------------
>=20
>=20
>=20
> --=20
> Sebastian Benoit <benoit-lists@fb12.de>
> My mail is GnuPG signed -- Unsigned ones are bogus -- http://www.gnupg.or=
g/
> GnuPG 0x5BA22F00 2001-07-31 2999 9839 6C9E E4BF B540  C44B 4EC4 E1BE 5BA2=
 2F00
>=20
> Oxymoron #633: Mutual Differences



--=20
Sebastian Benoit <benoit-lists@fb12.de>
My mail is GnuPG signed -- Unsigned ones are bogus -- http://www.gnupg.org/
GnuPG 0x5BA22F00 2001-07-31 2999 9839 6C9E E4BF B540  C44B 4EC4 E1BE 5BA2 2=
F00

The political and commercial morals of the United States are not merely food
for laughter, they are an entire banquet. -- Mark Twain

--qcHopEYAB45HaUaB
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAj20IMoACgkQTsThvluiLwAA/gCgptDWmYvz6P9IVOc85yfC/xN2
fvkAn1yogypzNBSgr4Fjge92BTYe5FYv
=ciQV
-----END PGP SIGNATURE-----

--qcHopEYAB45HaUaB--
