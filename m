From: Anton Arapov <aarapov@redhat.com>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 11:56:23 +0200
Message-ID: <m3wstvjnso.fsf@bandura.englab.brq.redhat.com>
References: <20071010085530.GA7532@iris.sw.ru>
	<m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
	<20071010.023515.15263796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, den@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742AbXJJJ4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:56:32 -0400
In-Reply-To: <20071010.023515.15263796.davem@davemloft.net> (David Miller's message of "Wed\, 10 Oct 2007 02\:35\:15 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

David Miller <davem@davemloft.net> writes:
>> Ok, I've got it, so we have to do the same with the following:
>> quote from inet_hashtables.c and inet6_hashtables.c. I'll prepare the
>> patch.
>>=20
>> And just a curious, does the /* Treat low > high as high =3D=3D low */
>> idea will keep after the sysctl will be patched?
>
> I'm beginning to think that we should do the sysctl validation
> in this patch too, instead of duplicating this grotty check
> in all of these port selection functions.
  Yep, that's exactly I'm talking about. I'm sure that=20
  [...] % (high - low) [...] erroneous from the begining, because
in such places we want to have 1 in denominator, for the cases when we
have only one port. Because 34000 34000 in sysctl's
ip_local_port_range means 1(one) port, not 0(zero).

  So it seems to me that we have to fix mentioned denominators in
kernel/net to have 1, that will be correct logically. And do the
MAX<MIN check in sysctl code.
  From this point of view, it's best idea to have two patches: one for
the kernel/net denominators and another one for the sysctl.c's
function dointvec_minmax(). Because they can live independently. And
the patch for the kernel/net will do the work at least because we
prevent kernel trap at all.
=20=20
  Dave, am I right?
=2D-=20
Anton Arapov, <aarapov@redhat.com>
Kernel Development, Red Hat
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHDKHLVub9yW+oyBIRAqs6AKDkaQJu8MWuIRU7dHQY/1cU1fNbqgCfSVoP
tKONDikOTL+tLDMIE5YfG2Q=
=qPI3
-----END PGP SIGNATURE-----
--=-=-=--
