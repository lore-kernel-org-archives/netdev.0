From: Joe M <joe9mail@gmail.com>
Subject: Re: [PATCH v2 net] ipv4: do not use this_cpu_ptr() in preemptible
 context
Date: Mon, 22 Sep 2014 14:09:53 -0500
Message-ID: <20140922190953.GA15929@master>
References: <20140922090242.5ef15c83@urahara>
 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411407496.26859.141.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:37959 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaIVTJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:09:56 -0400
Received: by mail-oi0-f51.google.com with SMTP id x69so4106108oia.24
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 12:09:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Eric,

Thanks for the quick fix.

> > v2: use latest and shiny raw_cpu_ptr(), as it seems the latest
> > incantation of ever changing percpu interface.
> >
> >  net/ipv4/ip_tunnel.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
The below grep shows 3 uses of this_cpu_ptr, whereas the patch only
replaces 2 instances. Just want to check if that is ok.

grep --ignore-case --exclude-dir=".git" --recursive this_cpu_ptr ip_tunnel.c
        __tunnel_dst_set(this_cpu_ptr(t->dst_cache), dst, saddr);
        idst = this_cpu_ptr(t->dst_cache);
        tstats = this_cpu_ptr(tunnel->dev->tstats);

Thanks
Joe

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUIHQBAAoJENvmPC7PRKkIhLUP/jH0llwzSakNGE7BoG9BA0jg
gENEx/pcRDFH5CHFBfi9Y8V593zDShKEXbP4vuSHVCnUMMubQJimGit0ekvLiKJR
OTZeZdPfNFhgNbaZqf36UySXkD0VMEL9H3D7Z3oXpuXScKSL5hduT9QnvUuRjoX9
5ZbJhL2SCz+wZnkbNZBQqb//d8OzFnEbdXSQ4Aum/9eokxf3rj3rnx7pDRTxd7O3
CjNLxBAzTZysf2MmG5bdbl51z79zwT8wgjO1fnPRa0aJA9bxlEtOpDUkLrE/zdtE
fHQysI7gZdmwLPwzegg+jiCwLLnfyV5TW43kvBB+JQs98FP5p6XHf3ZrAg3y57+/
halBEVT5m29GRizKSONSmWPN1p+tKrjo8rX2MmH/WHre+512G1q53ehLaMhU17wV
pyUj//hsXQyC6lvX2pVE3/5qFDEG/PkuL4goqYfQzq7h5akhve6cBXbw61CBUSDV
SI/CxHCCYXahGHbpO3VmagQ4t+2RWXRUQ/HZmafBsCVdnibmO7GzNRJ3+z/mdH+u
R6cunBNYBoBt5QSVwTZ8eIw8I94ltS1w20JV13Dqz6diQY+7Z5Tabxtp0KgPt9lt
p45k+rxsnzYqudgKTvewh7mnPHt/VZxFWGk8qXbnFcif0VrGpCjaODeVhVANuwY9
LMXBYumKIvU3MS5fWxqc
=uk1+
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
