From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 17:14:23 +0100
Message-ID: <4B43655F.5030807@gmail.com>
References: <4B4317AD.1040302@free.fr> <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi> <4B4348A7.4090509@gmail.com> <4B435EB5.1010902@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34650 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab0AEQOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 11:14:37 -0500
In-Reply-To: <4B435EB5.1010902@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 16:45, Daniel Lezcano a =E9crit :
 =20
> It's not problem if the set / get values are not same, but I was aski=
ng
> because I am working with a test suite checking if a checkpoint /
> restart solution is correct.  One of these tests, sets the
> TCP_DEFER_ACCEPT value to 12, checkpoints / restarts, and reads the
> value in order to check if it was correctly restored. The value 12 wa=
s
> chosen because it is not rounded, so we were able to safely do the te=
st.
> But with the 2.6.32, the behaviour changed, so I preferred to report =
it
> in case that is something not expected.
>=20
>=20

12 happened to be rounded to 12 with previous kernels,
but with recent kernels we have another conversion table :

1 -> 3
2 -> 3
3 -> 3
4 -> 9
5 -> 9
6 -> 9
7 -> 9
8 -> 9
9 -> 9
10 -> 21
=2E..
21 -> 21
22 -> 45
=2E..
45 -> 45
46 -> 93
=2E..
93 -> 93
94 -> 189
=2E..
189 -> 189
190 -> 309
=2E..
