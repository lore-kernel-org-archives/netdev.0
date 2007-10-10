From: Anton Arapov <aarapov@redhat.com>
Subject: Re: [PATCH] ipv4: kernel panic when only one unsecured port available
Date: Wed, 10 Oct 2007 10:19:33 +0200
Message-ID: <m3hckzl6ui.fsf@bandura.englab.brq.redhat.com>
References: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>
	<470C773C.2050700@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbXJJIUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 04:20:19 -0400
In-Reply-To: <470C773C.2050700@sw.ru> (Denis V. Lunev's message of "Wed\, 10 Oct 2007 10\:54\:52 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

Hi,

"Denis V. Lunev" <den@sw.ru> writes:
> This code is broken from the very beginning.
>
> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
> 32768   61000
> iris den # echo 32768 32 >/proc/sys/net/ipv4/ip_local_port_range
> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
> 32768   32
> iris den # echo 32768 61000 >/proc/sys/net/ipv4/ip_local_port_range

  If you're talking about checks in sysctl, I believe it should be
another patch for sysctl only, and I'm going to push it via -mm tree.

  the devision by zero exists in inet_connection_socket.c, and must be
fixed for sure because the situation with the same min and max port
numbers in sysctl are possible and not prohibited.

Cheers!
=2D-=20
Anton Arapov, <aarapov@redhat.com>
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHDIsZVub9yW+oyBIRAvaeAJ9xBaolAdYF26DUWOdgvXWNlMJ6cACg0K1y
6+yQ4TQisshzizUvJpFt5Mw=
=btNR
-----END PGP SIGNATURE-----
--=-=-=--
