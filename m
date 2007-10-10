From: Anton Arapov <aarapov@redhat.com>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 14:49:02 +0200
Message-ID: <m3sl4jjfsx.fsf@bandura.englab.brq.redhat.com>
References: <m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
	<20071010.023515.15263796.davem@davemloft.net>
	<m3wstvjnso.fsf@bandura.englab.brq.redhat.com>
	<20071010.030153.09951294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbXJJMtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 08:49:12 -0400
In-Reply-To: <20071010.030153.09951294.davem@davemloft.net> (David Miller's message of "Wed\, 10 Oct 2007 03\:01\:53 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

David Miller <davem@davemloft.net> writes:
> From: Anton Arapov <aarapov@redhat.com>
> Date: Wed, 10 Oct 2007 11:56:23 +0200
>
>>   Yep, that's exactly I'm talking about. I'm sure that=20
>>   [...] % (high - low) [...] erroneous from the begining, because
>> in such places we want to have 1 in denominator, for the cases when we
>> have only one port. Because 34000 34000 in sysctl's
>> ip_local_port_range means 1(one) port, not 0(zero).
>>=20
>>   So it seems to me that we have to fix mentioned denominators in
>> kernel/net to have 1, that will be correct logically. And do the
>> MAX<MIN check in sysctl code.
>>   From this point of view, it's best idea to have two patches: one for
>> the kernel/net denominators and another one for the sysctl.c's
>> function dointvec_minmax(). Because they can live independently. And
>> the patch for the kernel/net will do the work at least because we
>> prevent kernel trap at all.
>>=20=20=20
>>   Dave, am I right?
>
> Sure, two patches is fine.

  I have been mistaken. We can't modify sysctl code itself to do the
checks like (MAX_VAL < MIN_VAL), we have generic functions, and if we
want implement something like this we have to implement absolutely new
functionality, it's insane to do it. :)
  It seems to me, all we can is to make this check in code where the
MAX_VAL<MINVAL condition brakes logic.
  FTOH the patch that prevents do_divide_error trap is
enough... Kernel will keep working, with huge kernel panic notice in
dmesg. :)
  So, now the way suggested by Denis looks reasonable.

  What do you think?

=2D-=20
Anton Arapov, <aarapov@redhat.com>
Kernel Development, Red Hat
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHDMpCVub9yW+oyBIRAmbFAJ422OWOCARFQw8emLSXaWiX9/fIWgCcCEcn
DbdG/3psPi9pG7RFsXQLO7M=
=1oGq
-----END PGP SIGNATURE-----
--=-=-=--
