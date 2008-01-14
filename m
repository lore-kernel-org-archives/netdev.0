From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Mon, 14 Jan 2008 13:05:48 -0500
Message-ID: <31130.1200333948@turing-police.cc.vt.edu>
References: <30887.1200209733@turing-police.cc.vt.edu> <7197.1200327338@turing-police.cc.vt.edu>
            <200801141136.41140.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1200333948_3045P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:57322 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbYANSF7 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:05:59 -0500
In-Reply-To: Your message of "Mon, 14 Jan 2008 11:36:40 EST."
             <200801141136.41140.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1200333948_3045P
Content-Type: text/plain; charset=us-ascii

On Mon, 14 Jan 2008 11:36:40 EST, Paul Moore said:

> Are you still only seeing these problems on loopback?  I can't help but wonder 
> if this is the skb_clone() problem where it wasn't copying skb->iif causing 
> SELinux to silently drop the packets.

Yes, I've only spotted it on loopback.  The odd part is that I had reverted the
one commit 9c6ad8f6895db7a517c04c2147cb5e7ffb83a315 "Convert the netif code to
use ifindex values" - so either I managed to get the revert terribly wrong,
or there's something else odd going on.  The first time around, I was seeing
hangs during a TCP 3-packet handshake - this time data flows for some number
of packets before hanging.

I'm pulling  git://git.infradead.org/users/pcmoore/lblnet-2.6_testing at the
moment, and seeing if there's already a fix in there for this.


--==_Exmh_1200333948_3045P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHi6R8cC3lWbTT17ARArXKAKDffj0290XpKY6OITSMmqU9uGnHQACg9r43
Aw9JW6hnv12Wlfj2OQzS3jU=
=7/3J
-----END PGP SIGNATURE-----

--==_Exmh_1200333948_3045P--
