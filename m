From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 17:33:04 +0100
Message-ID: <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>
	 <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34436 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759502Ab1LPQdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 11:33:08 -0500
Received: by wgbdr13 with SMTP id dr13so6494733wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 08:33:07 -0800 (PST)
In-Reply-To: <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 16:58 +0100, Igor Maravi=C4=87=
 a =C3=A9crit :
> > 1) Why is it needed ? Any RFC requires this bloat ?
> >
>=20
> RFC4293 defines ipIfStatsTable.

Only as an option :

   In addition to the ipSystemStatsTable, the MIB includes the
   ipIfStatsTable.  This table counts the same items as the system tabl=
e
   but does so on a per interface basis.  It is optional and may be
   ignored.  If you decide to implement it, you may wish to arrange to
   collect the data on a per-interface basis and then sum those counter=
s
   in order to provide the aggregate system level statistics.  However,
   if you choose to provide the system level statistics by summing the
   interface level counters, no interface level statistics can be lost =
-
   if an interface is removed, the statistics associated with it must b=
e
   retained.

If not enough memory is available, we cannot up the interfaces anymore
after your patches. Some people disable ipv6 on their machines because
they setup thousand of interfaces, and added memory cost of
ipIfStatsTable on IPv6 is huge.

> Also I did it because ipv6 has per interface stats.

I was considering _removing_ them, or make it optional.

Memory costs are huge for percpu data.

>=20
> > 2) Every patch in a patch serie must be compilable. Think about
> > bisection. This is mandatory.
> >
>=20
> OK, I didn't know about that...
> Do I need to resubmit it? If I do, I'l do that in monday.

As I said, this is _mandatory_.

Before spending time on this stuff, please wait for other people
comments.

> Would it be acceptable to send it as one big patch?

I dont think so, its too big.
