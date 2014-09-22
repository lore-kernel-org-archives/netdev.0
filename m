From: Joe M <joe9mail@gmail.com>
Subject: Re: [PATCH v2 net] ipv4: do not use this_cpu_ptr() in preemptible
 context
Date: Mon, 22 Sep 2014 14:17:12 -0500
Message-ID: <20140922191712.GA21111@master>
References: <20140922090242.5ef15c83@urahara>
 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411407496.26859.141.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:52508 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbaIVTRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:17:14 -0400
Received: by mail-oi0-f43.google.com with SMTP id v63so3739613oia.2
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 12:17:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Eric, Tom,

> > this_cpu_ptr() in preemptible context is generally bad
> >
> > Sep 22 05:05:55 br kernel: [   94.608310] BUG: using smp_processor_id()
> > in
> > preemptible [00000000] code: ip/2261
> > Sep 22 05:05:55 br kernel: [   94.608316] caller is
> > tunnel_dst_set.isra.28+0x20/0x60 [ip_tunnel]
> > Sep 22 05:05:55 br kernel: [   94.608319] CPU: 3 PID: 2261 Comm: ip Not
> > tainted
> > 3.17.0-rc5 #82
> >
> > We can simply use raw_cpu_ptr(), as preemption is safe in these
> > contexts.
> >
> > Should fix https://bugzilla.kernel.org/show_bug.cgi?id=84991
> >
Thanks, the fix worked. I do not see the BUG message anymore.

Joe

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUIHW4AAoJENvmPC7PRKkI8dUP/2g85Id+UjNYAuoU3DqgPnsu
S4rtF9k7PZK/0CxxxY7gbxm6ndMEKdR8nSJ1FU/mstARAJLIl+p/qNU2OJtfzJrk
DM7p/nCjBDjznetNjVh+U4TRqOVea8kb3YuGfRgzHxAi3uIrSa++cbH5ipd7mstc
UBO5K617RWL8mA7I7/2di2E3NEKH3CLl25QqL69c6Ag8wQphLB3s8MMxdy3SmOOi
vpBGid5bZakx2M5nVtsXOMThFw30TyAiRHViWzFiywNagH7NHcxc8LOPAhvyJxFS
qXuMmyfZeYLZEyBI7Jnbz3txrYis+sWqfbkoeb1spnvt76+dYj2y6O906+q52nhM
Q6q3CN07pi5miR56ExSmbCJg51xhrpoYhu4TO2mgJGDXsUC1nU9hNdaLuf7OTc/C
Gys0IvhOzXd8FbsY769+oZATGSj3tdJWJbmui9xz0W0Nz4TvmbtzE5614Kz0cgC+
ZmsNrdyN0RoS2SMSuhkYxxPZYaXwny+1ZZ3KN6nu6ZOAuMOoPsVNKfwJIV+zh7y3
iDl+5A1KQjSfGnFxVcq6pxMdJwUBouqIhNFb6fPocSAqLg4UqYjPXN3gXJCLwczT
8/VWxLbi0AM6p3QGisMzQHfXG15JUeJ+M9VSCu9Efs93k6aiUmPfNJrp63QTBm2s
6iTvPIzp/Rp9euYLseAe
=GHNg
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
