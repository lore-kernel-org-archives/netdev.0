From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 15 Jun 2010 14:12:52 +0200
Message-ID: <1276603972.2541.99.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop> <20100615102541.GH6138@laptop>
	 <1276598605.2541.96.camel@edumazet-laptop>  <20100615110413.GJ6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43123 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab0FOMSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 08:18:49 -0400
Received: by mail-wy0-f174.google.com with SMTP id 40so4729058wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 05:18:48 -0700 (PDT)
In-Reply-To: <20100615110413.GJ6138@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 21:04 +1000, Nick Piggin a =C3=A9crit :

> So if you have a regular seqlock, the sequence:
>=20
> write_seqcount_begin
> stat1++
> stat2--
> write_seqcount_end
>=20
> do read_seqcount_begin
>   sum =3D stat1+stat2;
> while (read_seqcount_retry)
> BUG_ON(sum !=3D 0);
>=20
> This code is OK. But if it is using your stat sync, then it is buggy.
> This is obvious to you of course, but someone who doesn't consider
> the implementation might get caught out.
>=20
> I guess all my other points are properties of seqcount code itself,
> but they are not documented really well with the seqlock API
> unfortunately.
>=20

Yep, not counting fact that stat_sync is a noop on 64 bits anyway, so
external synchronization is pretty much needed (and probably already
present on all path were I need this stuff. If not, it must be fixed)



