From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 16:09:46 +0200
Message-ID: <200705281609.49859.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705280240.17910.maxi@daemonizer.de> <200705281216.51690.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2680567.p56DHj8tbN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705281216.51690.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart2680567.p56DHj8tbN
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 28 May 2007, Michael Buesch wrote:
> Can you give 2.6.16 a try? The diff is not that big and we might
> be able to find out what broke if you find out 2.6.16 works.
> You can also try later kernels like .17, .18, .19 to further
> reduce the patch. (You could also git-bisect, if you have the time).
>
I did some testing and compiled some kernels and here are the results:

I was able to find out what causes the problems for me.  I did build two=20
2.6.21.3 kernels, and one does work fine and the other doesn't.

This is a diff of the kernel configs I used:

=2D-- /usr/src/linux-2.6.21.3-oldconfig1/.config  2007-05-28 13:41:15.00000=
0000=20
+0200
+++ /usr/src/linux-2.6.21.3/.config     2007-05-28 14:46:08.000000000 +0200
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.21.3
=2D# Mon May 28 13:41:15 2007
+# Mon May 28 14:46:09 2007
 #
 CONFIG_X86_32=3Dy
 CONFIG_GENERIC_TIME=3Dy
@@ -32,7 +32,7 @@
 #
 # General setup
 #
=2DCONFIG_LOCALVERSION=3D"-oldconfig1"
+CONFIG_LOCALVERSION=3D""
 CONFIG_LOCALVERSION_AUTO=3Dy
 CONFIG_SWAP=3Dy
 CONFIG_SYSVIPC=3Dy
@@ -108,9 +108,9 @@
 #
 # Processor type and features
 #
=2D# CONFIG_TICK_ONESHOT is not set
+CONFIG_TICK_ONESHOT=3Dy
 # CONFIG_NO_HZ is not set
=2D# CONFIG_HIGH_RES_TIMERS is not set
+CONFIG_HIGH_RES_TIMERS=3Dy
 # CONFIG_SMP is not set
 CONFIG_X86_PC=3Dy
 # CONFIG_X86_ELAN is not set

The -oldconfig1 is the kernel that had no problems and the other shows the =
b44=20
problem. So if High Resolution Timer Support is disabled everything works=20
fine and if I enable it the problems do appear again.

I didn't test this on my 2.6.22-rc3 kernel yet, but I guess disabling High=
=20
Resolution Timer Support will also solve the problem there.

The older kernels I tried also work perfectly fine and they didn't have the=
=20
High Resolution Timer Support yet.

Maxi

--nextPart2680567.p56DHj8tbN
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGWuKtOimwv528XGERAtQ1AKCFy7ttCAxrsBSsWI4oPFp0Gplw/ACg+PAd
xraG3X/P9xk/wJpOGllhhbc=
=07ZM
-----END PGP SIGNATURE-----

--nextPart2680567.p56DHj8tbN--
