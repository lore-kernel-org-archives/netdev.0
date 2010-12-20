From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Mon, 20 Dec 2010 18:13:53 +0100
Message-ID: <1292865233.2800.192.camel@edumazet-laptop>
References: <m1sjzs3hbw.fsf@fess.ebiederm.org>
	 <20101026.122022.241452738.davem@davemloft.net>
	 <1288121422.2652.14.camel@edumazet-laptop>
	 <20101219.211453.226783693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	daniel.lezcano@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:56118 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab0LTRVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 12:21:37 -0500
Received: by wwi17 with SMTP id 17so3049364wwi.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 09:21:35 -0800 (PST)
In-Reply-To: <20101219.211453.226783693.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 d=C3=A9cembre 2010 =C3=A0 21:14 -0800, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 Oct 2010 21:30:22 +0200
>=20
> > Le mardi 26 octobre 2010 =C3=A0 12:20 -0700, David Miller a =C3=A9c=
rit :
> >> From: ebiederm@xmission.com (Eric W. Biederman)
> >> Date: Tue, 26 Oct 2010 12:05:39 -0700
> >>=20
> >> >> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier=
_block *this, unsigned long event, vo
> >> >>  		rt_cache_flush(dev_net(dev), 0);
> >> >>  		break;
> >> >>  	case NETDEV_UNREGISTER_BATCH:
> >> >> -		rt_cache_flush_batch();
> >> >> +		rt_cache_flush_batch(dev_net(dev));
> >> >=20
> >> > It still has this incorrect conversion in it.
> >>=20
> >> Sorry I missed that, what's the exact problem with it?
> >=20
> > Because the way _BATCH operation is performed, we call it once...
> >=20
> > rollback_registered_many() calls it for the first dev queued in the
> > list.
> >=20
> > So it should be net independant.
>=20
> Thanks Eric.  I finally got back to fixing this issue and respinning
> the patch.
>=20
> Please review, in particular how I handled the RCU bits.
>=20
> --------------------
> ipv4: Flush per-ns routing cache more sanely.
>=20
> Flush the routing cache only of entries that match the
> network namespace in which the purge event occurred.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>


Seems fine to me, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


