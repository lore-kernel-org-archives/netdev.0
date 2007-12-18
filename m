From: Valdis.Kletnieks@vt.edu
Subject: 2.6.24-rc5-mm1 - IPv6 throws section mismatches.
Date: Tue, 18 Dec 2007 01:10:48 -0500
Message-ID: <4509.1197958248@turing-police.cc.vt.edu>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1197958248_2928P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hc652a898.dhcp.vt.edu ([198.82.168.152]:47287 "EHLO
	hc652a898.dhcp.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483AbXLRPNw (ORCPT
	<RFC822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 10:13:52 -0500
In-Reply-To: Your message of "Thu, 13 Dec 2007 02:40:50 PST."
             <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1197958248_2928P
Content-Type: text/plain; charset=us-ascii

On Thu, 13 Dec 2007 02:40:50 PST, Andrew Morton said:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc5/2.6.24-rc5-mm1/

git-net.patch (I'm guessing one of Daniel's commits, but not sure which one)
causes some complaints:
 
  LD      vmlinux.o
  MODPOST vmlinux.o
WARNING: vmlinux.o(.init.text+0x2263f): Section mismatch: reference to .exit.text:tcpv6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x22644): Section mismatch: reference to .exit.text:udplitev6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x22649): Section mismatch: reference to .exit.text:udpv6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x22658): Section mismatch: reference to .exit.text:addrconf_cleanup (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x226bc): Section mismatch: reference to .exit.text:rawv6_exit (between 'inet6_init' and 'ac6_proc_init')

Looks like the problem is that tcpv6_exit and friends are called from
net/ipv6/af_inet6.c:inet6_init() - which is declared as:

static int __init inet6_init(void)

I can see how calling an __exit from an __init would be Bad Juju...


--==_Exmh_1197958248_2928P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHZ2RocC3lWbTT17ARAtpWAJ48XLNtLwKol8ED/TBDjUw4qWX3zgCcDN4g
JMHFjQUfgRx0x/+hog63B7k=
=Wg2z
-----END PGP SIGNATURE-----

--==_Exmh_1197958248_2928P--
