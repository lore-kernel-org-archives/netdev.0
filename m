From: Joe M <joe9mail@gmail.com>
Subject: Re: [PATCH v2 net] ipv4: do not use this_cpu_ptr() in preemptible
 context
Date: Mon, 22 Sep 2014 14:34:51 -0500
Message-ID: <20140922193451.GA23177@master>
References: <20140922090242.5ef15c83@urahara>
 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411407496.26859.141.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
 <20140922190953.GA15929@master>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:55853 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaIVTex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:34:53 -0400
Received: by mail-oi0-f47.google.com with SMTP id e131so3756356oig.20
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 12:34:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140922190953.GA15929@master>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Eric,

> > > v2: use latest and shiny raw_cpu_ptr(), as it seems the latest
> > > incantation of ever changing percpu interface.
> > >
> > >  net/ipv4/ip_tunnel.c |    4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > >
> The below grep shows 3 uses of this_cpu_ptr, whereas the patch only
> replaces 2 instances. Just want to check if that is ok.
>=20
> grep --ignore-case --exclude-dir=3D".git" --recursive this_cpu_ptr ip_tun=
nel.c
>         __tunnel_dst_set(this_cpu_ptr(t->dst_cache), dst, saddr);
>         idst =3D this_cpu_ptr(t->dst_cache);
>         tstats =3D this_cpu_ptr(tunnel->dev->tstats);

grep --ignore-case --exclude-dir=3D".git" --recursive this_cpu_ptr *.c
ip_input.c:             struct ip_rt_acct *st =3D this_cpu_ptr(ip_rt_acct);
ip_vti.c:       tstats =3D this_cpu_ptr(dev->tstats);
route.c:                p =3D (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_=
rth_output);
route.c:                        prth =3D __this_cpu_ptr(nh->nh_pcpu_rth_out=
put);
tcp.c:          return __this_cpu_ptr(p);

Is it ok for ip_vti.c and ip_input.c to use this_cpu_ptr?

Thanks
Joe

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUIHnbAAoJENvmPC7PRKkInZ4P/igtxUKkqeGSfajmtqyQ4w6P
loOO4wYjP3QMgsSr5XHJPjkMjlw8GGChA9IrktAhu/ze0lGPJY/fdNjjKO+GcJ9W
5kJcrsuJ0ZlGHIOBe7aBSm4cOMXT9bECr+1MajNTRUbZa69xkg41LMjLW5Uh3++/
WlB714ypsBKV2n632g2x7ID43qS/CUhNCfdoNmyzXT6v8SJHFDuMZFBMmiIRbxs6
8ff7heIJN3xn+1KOQrCUKOs8w/EO3J4wmWbuvFXoTRg2F7S6cGhTGCfYCQ8G+o9I
PWln1yT3EkSGOI6+RFmD6RgwJqntXWS3U0jC6SuuZ9m/k4m3gIa+hDxU3CCxgZm6
EtkaZ+/Q7Os7ec9cB8wfsyvwiuEnBFvSJGYyFsI4CWTSmIW7y4oBaf0hPKfInNxp
kzsngteRM3XQIASOQS1tYnUvReonnxAX8JK6NwBb/2AangHYC829QCFJv5SKFHOu
GLu20/0jByF8QbK+c+UdBwttHFTk250VrgyZTZMqBztbtCGppsIa/JDAsea0D+sm
qy9t095W7ZgJLmBZtEMX6RVBmcB1YF6aGGOPsuW6l8RxtIWCnMlv2bSyQoDtq6UU
Ws+4pbjxOFUdUOE3JX7Si/lAc+nW7Y5e9++bs8JJhxZgdgHwXqm+usyxV92yyD+a
Qq4gPMt0cKmBWRroUwvT
=l8O6
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--
