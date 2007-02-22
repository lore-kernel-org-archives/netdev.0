From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] fix limited slow start bug
Date: Thu, 22 Feb 2007 16:52:03 -0500
Message-ID: <45DE1083.6040900@psc.edu>
References: <45DDE756.20001@psc.edu> <Pine.LNX.4.64.0702222317000.29273@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:61149 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751960AbXBVVwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 16:52:17 -0500
In-Reply-To: <Pine.LNX.4.64.0702222317000.29273@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> BTW, while looking this patch, I noticed that snd_cwnd_clamp is only =
u16=20
> while snd_cwnd is u32, which seems rather strange since snd_cwnd is b=
eing=20
> limited by the clamp value here and there?!?! And tcp_highspeed.c is=20
> clearly assuming even more than this (but the problem is hidden as=20
> snd_cwnd_clamp is feed back to the min_t and the used 32-bit constant=
=20
> could be safely cut to 16-bits anyway):
>=20
>   tp->snd_cwnd_clamp =3D min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/12=
8);
>=20
> Has the type being changed somewhere in the past or why is this so?

It's been that way as long as I can remember.  It's always been a=20
mystery to me as well.  I suspect the tcp_highspeed code is that way=20
because this patch originally came out of the Web100-patched kernel,=20
which at one point was using a 32 bit snd_cwnd_clamp IIRC.

I think it's not unreasonable to change clamp to 32 bits now, since wit=
h=20
1500 byte packets, this corresponds to a max cwnd of ~94MB.  This is=20
pretty big, but we are currently right at this limit with 10 GigE.

   -John
