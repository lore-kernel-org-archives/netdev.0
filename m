From: Harald Welte <laforge@gnumonks.org>
Subject: lnstat (rtstat replacement)
Date: Sat, 2 Oct 2004 18:21:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002162120.GT27499@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QHhm1I6mwQR20oIa"
Cc: David Miller <davem@davemloft.net>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Netdev List <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--QHhm1I6mwQR20oIa
Content-Type: multipart/mixed; boundary="IUSVF+LtaR4kWxuH"
Content-Disposition: inline


--IUSVF+LtaR4kWxuH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I've finished my work on 'lnstat'.  The current development version is
available from
	http://svn.gnumonks.org/cgi-bin/viewcvs.cgi/trunk/lnstat/
where you can select the 'download tarball' option.

I've added and tested support for old kernels, where it tries to fall
back to rtstat compatibility mode via /proc/net/rt_cache_stat.

README attached to this email.

Robert: I hope you're fine with the new lnstat tool replacing rtstat.

Stephen:  Feel free to grab the current version and add it to the next
iproute2 release.  Please send any changes you integrate back upstream
to me, so I can merge them into my repository.

Dave:  I've also attached a small patch for Documentation/networking.
Please add this to the same patchset that includes /proc/net/stat
support.

Everyone:  If you have suggestions/comments/feature requests, feel free
to tell me.=20

Thanks!

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--IUSVF+LtaR4kWxuH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="laforge-neighstat-doc.patch"
Content-Transfer-Encoding: quoted-printable

Index: linux-2.6.9-rc2-bk9-neigh1/Documentation/networking/statistics.txt
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.9-rc2-bk9-neigh1/Documentation/networking/statistics.txt	2004=
-10-02 18:15:23.485872616 +0200
@@ -0,0 +1,40 @@
+Statistics exported via /proc/net/stat - Added in 2.6.9
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+(C) 2004 by Harald Welte <laforge@gnumonks.org>
+
+/proc/net/stat is a generalized replacement for /proc/net/rt_cache_stat.
+
+In addition to routing cache statistics, it supports any kind of statistics
+the linux kernel exports via a file in /proc/net/stat.  In a stock 2.6.9
+kernel, this is=20
+	per-protocol neighbour cache statistics=20
+		(ipv4, ipv6, atm, decnet)
+	routing cache statistics
+		(ipv4)
+	connection tracking statistics
+		(ipv4)
+
+
+In order to get a convenient reading of those statistics, a tool called
+'lnstat' is provided at http://svn.gnumonks.org/trunk/lnstat
+
+This tool is to be integrated in the next release of the iproute2 program.
+
+
+If you want to add your own kernel statistics to /proc/net/stat, the file =
has
+to have the following properties:
+
+0) Field seperator is always one or two spaces.  No tabs, etc.
+
+1) First line consists out of a template of field names.  This is usually =
the
+   structure member names of the statistics structure you want to dump
+
+2) All following lines consists of unsigned hexadecimal values. One line p=
er
+   available CPU.  Only as many fields as specified in template line.
+
+3) Please test if it works with the 'lnstat' tool before submitting a patch
+   to the kernel.
+
+Any questions should be directed to netdev@lists.oss.sgi.com or to the aut=
hor
+of this document.
+

--IUSVF+LtaR4kWxuH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=README
Content-Transfer-Encoding: quoted-printable

lnstat - linux networking statistics
(C) 2004 Harald Welte <laforge@gnumonks.org
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

This tool is a generalized and more feature-complete replacement for the old
'rtstat' program.

In addition to routing cache statistics, it supports any kind of statistics
the linux kernel exports via a file in /proc/net/stat.  In a stock 2.6.9
kernel, this is=20
	per-protocol neighbour cache statistics=20
		(ipv4, ipv6, atm, decnet)
	routing cache statistics
		(ipv4)
	connection tracking statistics
		(ipv4)

Please note that lnstat will adopt to any additional statistics that might =
be
added to the kernel at some later point

I personally always like examples more than any reference documentation, so=
 I
list the following examples.  If somebody wants to do a manpage, feel free
to send me a patch :)

EXAMPLES:

In order to get a list of supported statistics files, you can run

	lnstat -d

It will display something like
=20
/proc/net/stat/arp_cache:
         1: entries
         2: allocs
         3: destroys
[...]
/proc/net/stat/rt_cache:
         1: entries
         2: in_hit
         3: in_slow_tot

You can now select the files/keys you are interested by something like

	lnstat -k arp_cache:entries,rt_cache:in_hit,arp_cache:destroys

arp_cach|rt_cache|arp_cach|
 entries|  in_hit|destroys|
       6|       6|       0|
       6|       0|       0|
       6|       2|       0|


You can specify the interval (e.g. 10 seconds) by:
=09
	lnstat -i 10

You can specify to only use one particular statistics file:

	lnstat -f ip_conntrack

You can specify individual field widths=20

	lnstat -k arp_cache:entries,rt_cache:entries -w 20,8

You can specify not to print a header at all
=09
	lnstat -s 0

You can specify to print a header only at start of the program

	lnstat -s 1

You can specify to print a header at start and every 20 lines:

	lnstat -s 20

You can specify the number of samples you want to take (e.g. 5):
=09
	lnstat -c 5


--IUSVF+LtaR4kWxuH--

--QHhm1I6mwQR20oIa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBXtWAXaXGVTD0i/8RAuFyAJ9A/CiTrNMZCYuVIUtHnLiVMF9FJgCgmauc
o6+PXCZgzDLPMW6skWy86T8=
=XpHc
-----END PGP SIGNATURE-----

--QHhm1I6mwQR20oIa--
