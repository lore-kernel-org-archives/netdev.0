From: Dominick Grift <dac.override@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Tue, 12 May 2015 20:27:42 +0200
Message-ID: <20150512182741.GD9693@x131e>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
 <20150504133943.GA17043@x131e>
 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
 <20150504132714.55dca5b0@urahara>
 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
 <20150511131516.GC10375@x131e>
 <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="AkbCVLjbJ9qUtAXD"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35174 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932902AbbELS1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 14:27:47 -0400
Received: by wgnd10 with SMTP id d10so17097882wgn.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 11:27:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AkbCVLjbJ9qUtAXD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 11, 2015 at 07:53:06AM -0700, Eric Dumazet wrote:
>=20
> Hi Dominick
>=20
> Have you tried this patch I sent last monday ?
>=20
> I will submit formally when I get a test result.
>=20
> Thanks

Eric,

I have tested the below patch and everything is in order!

Thank you!

>=20
> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> index 4fcaa67750fda845ad0a180332c4cd96a9524086..7caf7fae2d5b8aa369b924e1c=
87a47c343fb8954 100644
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -97,7 +97,9 @@ static void br_forward_delay_timer_expired(unsigned lon=
g arg)
>  		netif_carrier_on(br->dev);
>  	}
>  	br_log_state(p);
> +	rcu_read_lock();
>  	br_ifinfo_notify(RTM_NEWLINK, p);
> +	rcu_read_unlock();
>  	spin_unlock(&br->lock);
>  }
> =20
>=20
>=20

--=20
02DFF788
4D30 903A 1CF3 B756 FB48  1514 3148 83A2 02DF F788
http://keys.gnupg.net/pks/lookup?op=3Dvindex&search=3D0x314883A202DFF788
Dominick Grift

--AkbCVLjbJ9qUtAXD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBCgAGBQJVUkYYAAoJENAR6kfG5xmcaNoL/RMjmG/cZQKjGZoFVy6UvA33
iTcy0yGoizvcWCYOpXmrUWxNCNEVjzkiWfcf4iPGt8xxZOjqWm5VTsBecS2hrZKv
81/cLlulyVCRAO4oomQ85k/UUQzSTMzJvko4pe1PufIyvtO1PFXiXuBhkRunqgHk
q1TzGLf6my4s5ch6iAfzmHwld+6gYauCjIMTMejklriRceMRH1lgj6qoIMY96n+D
0STr2EJNXNi1Dn1KMGmV9g0IQpF0Lw9ejkRa0GOV5gTprgB1GjclcLNf4lXY7M7V
ygXVgloTJCTFefV9zFwJ0B5WuNePf99DUg16eMmHZ0gvKJdoSnXQ4IMsJ8KJK5SC
XaFKdVYWc/cbG3My06cNOyFDN+w90iTsOmZj57aZxlLlVjoTneDemkqtwvBNp4Oi
/Ox7Ika1GL5lawS8wx+Ge3yPjPnqGetUbYX4LuF6hF2APZj6CmZ3kQFt/Ri1mmfK
HdsEcLyK1UPBHGenSDq+b6tg/pLLQm1qGb/SYwRAjg==
=s0h1
-----END PGP SIGNATURE-----

--AkbCVLjbJ9qUtAXD--
