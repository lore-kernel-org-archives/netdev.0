From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: PROBLEM: Memory leak in -test9?
Date: Tue, 11 Nov 2003 13:06:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111130615.23006c98.akpm@osdl.org>
References: <20031111130513.67caea63.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, thomas@habets.pp.se
In-Reply-To: <20031111130513.67caea63.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
>=20
> A memory leak in the tcp6_sock slab.
>=20



Begin forwarded message:

Date: Tue, 11 Nov 2003 18:27:12 +0100
From: Thomas Habets <thomas@habets.pp.se>
To: J=F6rn Engel <joern@wohnheim.fh-wedel.de>
Cc: Henrik Storner <henrik@hswn.dk>, linux-kernel@vger.kernel.org
Subject: Re: PROBLEM: Memory leak in -test9?


-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 11 November 2003 17:27, J=F6rn Engel wrote:
> Looks familiar.  Can you recreate and send the output from
> /proc/slabinfo?

Oh, I didn't notice that file. :-)
Recreating is just booting and waiting for a week, but the box is still u=
p.

This is the line that stands out (complete file attached, 137 lines).

tcp6_sock         111663 111664    960    4    1 : tunables   54   27    =
0 :=20
slabdata  27916  27916      0

I seem to remember a changelog mentioning a leak being fixed in ipv6 code=
,=20
but it looks like there may be another one? The only ipv6 service running=
 is=20
sshd, and the mrtg-sshs that go off every 5 minutes are NOT over ipv6.=20
netstat -na shows nothing interesting. Only the ssh I connect with uses a=
 bit=20
of ipv6 (ffff:1.2.3.4). So, one listening socket, and one established.

$ cat /proc/net/sockstat6
TCP6: inuse 2
UDP6: inuse 0
RAW6: inuse 0
FRAG6: inuse 0 memory 0

$ cat /proc/net/rt6_stats=20
0000 0006 0000 0008 0000 0008 0003

nothing over 6 in /proc/net/dev_snmp6/*

$ cat /proc/net/snmp6
Ip6InReceives                           223315
... just 0 ...
Ip6InDelivers                           223312
... just 0 ...
Ip6OutRequests                          223312
.. nothing that looks interesting ...


- ---------
typedef struct me_s {
  char name[]      =3D { "Thomas Habets" };
  char email[]     =3D { "thomas@habets.pp.se" };
  char kernel[]    =3D { "Linux 2.4" };
  char *pgpKey[]   =3D { "http://www.habets.pp.se/pubkey.txt" };
  char pgp[] =3D { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" }=
;
  char coolcmd[]   =3D { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/sRvwKGrpCq1I6FQRAqw1AKDVu+ZEvqwdoFPD18g6Ps1+UG62cACfTatK
pHUgMxWIGHke3USjtUEsKZU=3D
=3D/5YW
-----END PGP SIGNATURE-----
