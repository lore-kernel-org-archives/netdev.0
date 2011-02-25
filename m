From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel modules
Date: Fri, 25 Feb 2011 12:25:40 -0500
Message-ID: <135187.1298654740@localhost>
References: <20110224151238.GA16916@albatros> <1298565265.2613.16.camel@bwh-desktop> <20110225123023.GA8776@albatros>
            <20110225151414.GA5211@albatros>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1298654740_47234P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>, Jesse Gross <jesse@nicira.com>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:50642 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932595Ab1BYR2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 12:28:34 -0500
In-Reply-To: Your message of "Fri, 25 Feb 2011 18:14:14 +0300."
             <20110225151414.GA5211@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1298654740_47234P
Content-Type: text/plain; charset=us-ascii

On Fri, 25 Feb 2011 18:14:14 +0300, Vasiliy Kulikov said:
> Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
> CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
> that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are limited
> to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't allow
> anybody load any module not related to networking.
> 
> This patch restricts an ability of autoloading modules to netdev modules
> with explicit aliases.  Currently there are only three users of the
> feature: ipip, ip_gre and sit.

And you stop an attacker from simply recompiling the module with a suitable
MODULE_ALIAS line added, how, exactly?  This patch may make sense down the
road, but not while it's still trivial for a malicious root user to drop stuff
into /lib/modules.

And if you're going the route "but SELinux/SMACK/Tomoyo will prevent a malicious
root user from doing that", then the obvious reply is "this should be part of those
subsystems rather than something done one-off like this (especially as it has a chance
of breaking legitimate setups that use the current scheme).

--==_Exmh_1298654740_47234P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNZ+YUcC3lWbTT17ARAqtAAJ0diVCzG6c6fL4tKdbjkHbnAnDZuwCeLuwB
T7FgP2EiU7jfWM0LUNcn4oU=
=c8EY
-----END PGP SIGNATURE-----

--==_Exmh_1298654740_47234P--

