From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sat, 25 Sep 2010 08:06:37 +0200
Message-ID: <1285394797.2478.54.camel@edumazet-laptop>
References: <20100923212012.GA10925@electric-eye.fr.zoreil.com>
	 <20100924131842.26f1fb1f@dhcp-lab-109.englab.brq.redhat.com>
	 <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	 <20100924.223709.233700415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, sgruszka@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49758 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab0IYGGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 02:06:47 -0400
Received: by fxm3 with SMTP id 3so1100768fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 23:06:46 -0700 (PDT)
In-Reply-To: <20100924.223709.233700415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 22:37 -0700, David Miller a =C3=A9=
crit :
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Sat, 25 Sep 2010 00:24:34 +0200
>=20
> > Stanislaw Gruszka <sgruszka@redhat.com> :
> >> Francois Romieu <romieu@fr.zoreil.com> wrote:
> > [...]
> >> Anyway atomic allocation should not be used in process context.
> >=20
> > What do you mean ? tg3->open() does not seem to bother. It is not a=
lone.
>=20
> I think this is merely an indication that r8169 is more often
> used in systems that actually suspend/resume than tg3 is.  tg3
> ought to be doing this too for correctness, as should pretty much
> every network driver.
>=20

Sure  but most people use MTU=3D1500, so tg3 works well.

Only r8169 allocates high order pages even with normal MTU

> Stanislaw's patches are very reasonable, especially if the problem
> is happening.
>=20
> But yes a "Tested-by: " confirming the fix would really be
> appeciated before we apply this.
> --

Patch solves the suspend/resume, probably, but as soon as we receive
trafic, we can hit the allocation error anyway...



