From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 11:40:01 +0000
Message-ID: <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_46FBCE07-5480-4D5C-9105-12CC1C7E729C";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	Andrey Vagin <avagin@virtuozzo.com>,
	"Honda, Michio" <michio@netapp.com>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:39999 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbcFNLkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 07:40:05 -0400
In-Reply-To: <575FEA4B.2000603@virtuozzo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_46FBCE07-5480-4D5C-9105-12CC1C7E729C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On 2016-06-14, at 13:28, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
> Andrey (in Cc) has played with TCP_REPAIR recently, I guess he can =
know something.

Thanks for CC'ing him. We looked a little bit more into this:

When TCP_REPAIR is on, tcp_connect() directly calls tcp_finish_connect() =
before returning, passing NULL for skb, which causes sk_rx_dst_set() to =
be bypassed. Later, when TCP_REPAIR is being turned off, =
do_tcp_setsockopt() just does tcp_send_window_probe(), but apparently =
all the "dst" stuff is being bypassed then also, so the mss remains at =
TCP_MSS_DEFAULT.

Lars

--Apple-Mail=_46FBCE07-5480-4D5C-9105-12CC1C7E729C
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXX+0TAAoJEFS1wwm/cMFXSLwQAIKpr8CAOYKLd5t8eRRK5dQc
/Y2TvOG0deHP+D9hypfTUWKAkxKurRZZyX8WSGZ4IgCP2ie6x76wdDf/S5xfFqTm
qm7Jgsd80HGbBiXhOJwomjSSVyXF583N7JdK69XLKw8J+CmhD91CrX7QYxLelp0B
DezhPTFdK5HNuMyUfd4TuEgY4ijjIxi/zWjT2u5yEJ3LJbHAAIt65OzAQn7JLlxi
pAPJlEUVUbfUPdPTXEvtl8aaYZ+4BFyhOqXQGvAdHMDpZ15WpKKdu1pzHk5j9fNC
GPLKgETYoEJ20aGW8PIUfJklpHTUZJjWHWOaQylvJZuqZi1lDQv3p8Qpid2Bj9nE
q3ott1ljC2CVEz8sErfYk4zzTn4wx977ItglNKpiDdroDQmwEeIvxXKnOgbVEO1a
ad2Xg6NamDxomlzYYzJ07TP1s+XfxSYyi4JS+9S3CYfb0ZxfzOKAcRNqhc5EvzoQ
Krk5PqHnWT0vxaniv7zq8uPgPPef61A2yc+b72F479O7TXkF0FeBTdTMNnD3wf9/
DMgPqj0+fMb9pXa4U+f2uKI2ijYHn3TRuB7Gvw+Yw+px346LseQME6+4R5JuR+ma
3iiB1M3nwRsQod2YeMAjlxxoXWGoi9YbbKNDZH4dPmQJi0x0rfQHcr+0ayqsxMED
KH/C0byPrh4kA5eH1yoz
=vkeh
-----END PGP SIGNATURE-----

--Apple-Mail=_46FBCE07-5480-4D5C-9105-12CC1C7E729C--
