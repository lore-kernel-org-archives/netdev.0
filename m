From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 17:29:39 -0500
Message-ID: <99827.1231712979@turing-police.cc.vt.edu>
References: <1231676698.25018.147.camel@macbook.infradead.org> <1231678799.25018.195.camel@macbook.infradead.org> <58054.1231692502@turing-police.cc.vt.edu>
            <20090111.134937.135396505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231712979_4078P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:49455 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbZAKW3p (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:29:45 -0500
In-Reply-To: Your message of "Sun, 11 Jan 2009 13:49:37 PST."
             <20090111.134937.135396505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231712979_4078P
Content-Type: text/plain; charset=us-ascii

On Sun, 11 Jan 2009 13:49:37 PST, David Miller said:
> From: Valdis.Kletnieks@vt.edu
> Date: Sun, 11 Jan 2009 11:48:22 -0500
> 
> > One unanswered question:  What do we expect the system to do if they have this
> > patch, TIGON3=y, FIRMWARE_IN_KERNEL=n, and configure a netconsole for boot
> > messages?  I'm *hoping* the answer is "the netconsole doesn't come up at boot,
> > but can be re-enabled via the /sys/kernel/config/netconsole interface after
> > you've done an 'ifconfig eth0 up' or similar, or do a 'modprobe netconsole'.
> > 
> > Those seem like reasonable semantics to me - anybody got a different opinion?
> 
> Even better, how about nfsroot?  There is no "later", either you
> can mount to root filesystem or you fail.

I don't see any sane way for an nfsroot to work unless you've built the kernel
with TIGON3=y, and FIRMWARE=y.  Anything else is just crazy talk.  For that
case, I'd suggest we just do this:

Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--- linux-2.6.28-mmotm0109/Documentation/filesystems/nfsroot.txt.dist	2008-12-24 18:26:37.000000000 -0500
+++ linux-2.6.28-mmotm0109/Documentation/filesystems/nfsroot.txt	2009-01-11 17:27:31.000000000 -0500
@@ -30,6 +30,9 @@ In the networking options, kernel level 
 along with the types of autoconfiguration to support. Selecting all of
 DHCP, BOOTP and RARP is safe.
 
+In addition, your network interface driver must be selected as built-in,
+and if the card is a Tigon3 or other card that requires a firmware load
+to become functional, you need to select FIRMWARE_IN_KERNEL.
 
 
 



--==_Exmh_1231712979_4078P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJanLTcC3lWbTT17ARAugYAJ9fciw425S1g46gWUS6ZddGigI10gCg24ul
jto5m7FyVX+Yv9aWoxBgGVk=
=+xsA
-----END PGP SIGNATURE-----

--==_Exmh_1231712979_4078P--
