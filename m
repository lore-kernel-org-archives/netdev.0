From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 23:00:50 +0200
Message-ID: <1305666050.2691.4.camel@edumazet-laptop>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	 <20110517.164929.1737248436066795381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59127 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233Ab1EQVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:00:54 -0400
Received: by wya21 with SMTP id 21so722191wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:00:52 -0700 (PDT)
In-Reply-To: <20110517.164929.1737248436066795381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 16:49 -0400, David Miller a =C3=A9crit :
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 17 May 2011 13:02:25 -0700
>=20
> > I like it!  And this sounds like the sort of algorithm that NICs mi=
ght
> > be able to implement to solve the UDP/RSS unpleasantness, so even
> > better.
>=20
> Actually, I think it won't work.  Even Linux emits fragments last to
> first, so we won't see the UDP header until the last packet where it'=
s
> no longer useful.
>=20
> Back to the drawing board. :-/

Well, we could just use the iph->id in the rxhash computation for frags=
=2E

At least all frags of a given datagram should be reassembled on same
cpu, so we get RPS (but not RFS)



