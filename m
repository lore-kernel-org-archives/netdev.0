From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 9 Nov 2010 13:07:32 -0800
Message-ID: <AANLkTi=s9zr+yF-nr8MoHY6W6m=usR2fH=dPJx6voC34@mail.gmail.com>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
	<1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57603 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082Ab0KIVHe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 16:07:34 -0500
Received: by gwj21 with SMTP id 21so4659722gwj.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 13:07:33 -0800 (PST)
In-Reply-To: <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define PGV_FROM_VMALLOC 1

Why don't we always just use vmalloc, what's the benefit of get_user_pa=
ges?

> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* vmalloc failed, lets dig into swap her=
e
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 *flags =3D 0;

probably better to *flags &=3D ~PGV_FROM_VMALLOC;
(since some flags could have been set before this function was called)

> + =C2=A0 =C2=A0 =C2=A0 gfp_flags &=3D ~__GFP_NORETRY;
> + =C2=A0 =C2=A0 =C2=A0 buffer =3D (char *)__get_free_pages(gfp_flags,=
 order);

wouldn't this still cause problems because you're now requiring linear
memory again?
Would it be better to just fail at this point?
