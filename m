From: Anton Arapov <aarapov@redhat.com>
Subject: Re: [PATCH] ipv4: kernel panic when only one unsecured port available
Date: Wed, 10 Oct 2007 10:31:08 +0200
Message-ID: <m3bqb7l6b7.fsf@bandura.englab.brq.redhat.com>
References: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>
	<470C773C.2050700@sw.ru>
	<m3hckzl6ui.fsf@bandura.englab.brq.redhat.com>
	<470C8CF1.4050706@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbXJJIbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 04:31:49 -0400
In-Reply-To: <470C8CF1.4050706@sw.ru> (Denis V. Lunev's message of "Wed\, 10 Oct 2007 12\:27\:29 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

"Denis V. Lunev" <den@sw.ru> writes:
> Anton Arapov wrote:=20
>> "Denis V. Lunev" <den@sw.ru> writes:
>>> This code is broken from the very beginning.
>>>
>>> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
>>> 32768   61000
>>> iris den # echo 32768 32 >/proc/sys/net/ipv4/ip_local_port_range
>>> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
>>> 32768   32
>>> iris den # echo 32768 61000 >/proc/sys/net/ipv4/ip_local_port_range
>>=20
>>   If you're talking about checks in sysctl, I believe it should be
>> another patch for sysctl only, and I'm going to push it via -mm tree.
>>=20
>>   the devision by zero exists in inet_connection_socket.c, and must be
>> fixed for sure because the situation with the same min and max port
>> numbers in sysctl are possible and not prohibited.
>>=20
>> Cheers!
>
> your patch change nothing :( unfortunately. If I set '32768 32767' it
> will oops again.

  Patch prevents the system crash. System traps on division by zero.

  Your case(MAX<MIN) must be handled by sysctl. Do you want to say
that I have to join patch for sysctl.c to this one? It's bad idea.

=2D-=20
Anton Arapov, <aarapov@redhat.com>
Kernel Development, Red Hat
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHDI3PVub9yW+oyBIRAoZRAKCYQb9g/ujzuc1lb/xqE3HrAhnCGgCffzse
FbZnS2ym+nSrPyMNOX/AXg4=
=648A
-----END PGP SIGNATURE-----
--=-=-=--
