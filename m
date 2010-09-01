From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Wed, 01 Sep 2010 21:47:30 +0200
Message-ID: <1283370450.2484.19.camel@edumazet-laptop>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	 <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	 <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57703 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab0IATrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 15:47:35 -0400
Received: by wwj40 with SMTP id 40so412219wwj.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 12:47:34 -0700 (PDT)
In-Reply-To: <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 ao=C3=BBt 2010 =C3=A0 22:27 +0900, Tetsuo Handa a =C3=A9cri=
t :
> I tried to create and autobind 1048576 UNIX domain sockets using
> http://I-love.SAKURA.ne.jp/tmp/unixloop.asm on 2.6.18-194.11.1.el5.x8=
6_64,
> and found that it needs about 2GB of RAM. Thus, on systems where
> /proc/sys/fs/file-max is larger than 1048576, a local user can create=
 and
> autobind 1048576 UNIX domain sockets in order to let applications fal=
l into
>=20
>   while (1)
>   	yield();
>=20
> loop. Below is the patch (only compile tested) to avoid falling into =
this loop.
> Is there any reason a name has to be '\0' + 5 letters?
> Shoud I give up after checking 1048576 names rather than after checki=
ng
> 4294967296 names?

Yes please. Fix the bug first.

Then, a following patch to increase current limit, if necessary.

> ----------------------------------------

> =20
>  	err =3D -ENOMEM;
> -	addr =3D kzalloc(sizeof(*addr) + sizeof(short) + 16, GFP_KERNEL);
> +	addr =3D kzalloc(sizeof(*addr) + sizeof(short) + 19, GFP_KERNEL);

IMHO, this 16 or 19 value is wrong, we need less memory than that.

(But this will be adressed in a 2nd patch)

Thanks


