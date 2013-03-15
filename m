From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: atl1c issues on 3.8.2
Date: Fri, 15 Mar 2013 20:44:57 +0100
Message-ID: <20130315204457.21d46b89@milhouse>
References: <20130312161753.281681f2@milhouse>
	<1363103144.13690.12.camel@edumazet-glaptop>
	<20130312180942.4198e88e@milhouse>
	<1363154258.13690.40.camel@edumazet-glaptop>
	<1363271460.29475.14.camel@edumazet-glaptop>
	<20130314231746.44a93e4d@milhouse>
	<1363302362.29475.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/jpu0GWy2JSL2+1yJCHx41_n"; protocol="application/pgp-signature"
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:34884 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab3COTpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 15:45:19 -0400
In-Reply-To: <1363302362.29475.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/jpu0GWy2JSL2+1yJCHx41_n
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 15 Mar 2013 00:06:02 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> You could try various DEBUGing stuff, like CONFIG_DEBUG_PAGEALLOC and
> CONFIG_SLUB_DEBUG_ON

This bug is so weird, so I did some double-checking.
Just to minimize the mistakes on my side.
I compiled a kernel without the revert of the original commit
and without the skb fix you suggested.
It turns out that I am only able to reproduce the issue, if the ath9k inter=
face is
up while testing the atl1c ethernet.
And I also double-checked that reverting the original commit fixes the issu=
e.
No stalls with up or down ath9k then.
So that confirms my previous results.

I tried to enable pagealloc debug and slub debug on a kernel with the sugge=
sted skb
fix, but without the revert of the commit. Nothing special appeared
in the logs. I'm currently building a kernel with almost all debugging opti=
ons
turned on. I will test that tomorrow.

Thanks for your help.

--=20
Michael

--Sig_/jpu0GWy2JSL2+1yJCHx41_n
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRQ3o5AAoJEPUyvh2QjYsOaxAQAKKvu8YFF5MDG3NuM4CAb+cM
3xGIrmvLnRDuVyBbeVHA/TaJrGPqbaQFxgMagP4dqOpNRDyDHHgdEUyrl/DmMCxz
YKl92pNwDl062jTSUalMndx9Rk/I0HaWVSudLKXtyE80zDcBRfn/xKUOlmwJDanP
RyXjNLObyJ5fsXr8kNmF73m4rX9DBQ60XStNgoRT5A9dGv+68CXprCUctZtIAetP
GRKKnZFEduCm9X/KnjC5hnaAff2MDIXjbbN9GcJsfc3I5UKJ/AuejKGaLJBXfnEk
6SES0u+qsZ/Dc9AJzvU3+ljxWgC0/oU+1zxgPu7uKRQVIW0SFB1xNFLSSmixp9sd
63YCXn+m03kBeC+sSXQOL4VlON0nKbhWvTnhdmIPmsuepbnJ8y4WSl/hajtTvGSZ
YoFyXbX3cEPWVQLKOHwM4nW4aj1EoWO16r+AN3AGsc/18Xen8b/zaGieCVsF92Ug
vn1ixtcSrIQn+JvYRGS4O2QsAql0l+l2hveyib5YmuCsF27Xox4WuMt2xPD1sc/6
6lhpL+NsYjNGqmYgTdie9gMKR17er3lqA4QxKeV24nuExiFM7qkNeH5TNS3AKG1E
61Uh/tcsnE9r3b08sCXuRYngGm3gUvijO7FTiNiiK9psMP8lo9e8QvF6soHYvOYU
lHn8WTH0K6tHalNLgXAK
=h8YN
-----END PGP SIGNATURE-----

--Sig_/jpu0GWy2JSL2+1yJCHx41_n--
