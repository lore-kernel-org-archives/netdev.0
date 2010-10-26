From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 21:30:22 +0200
Message-ID: <1288121422.2652.14.camel@edumazet-laptop>
References: <20101026.103428.179941457.davem@davemloft.net>
	 <m1sjzs3hbw.fsf@fess.ebiederm.org>
	 <20101026.122022.241452738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	daniel.lezcano@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59737 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab0JZTa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:30:27 -0400
Received: by wwe15 with SMTP id 15so5104327wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 12:30:26 -0700 (PDT)
In-Reply-To: <20101026.122022.241452738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 12:20 -0700, David Miller a =C3=A9crit =
:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 26 Oct 2010 12:05:39 -0700
>=20
> >> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_bl=
ock *this, unsigned long event, vo
> >>  		rt_cache_flush(dev_net(dev), 0);
> >>  		break;
> >>  	case NETDEV_UNREGISTER_BATCH:
> >> -		rt_cache_flush_batch();
> >> +		rt_cache_flush_batch(dev_net(dev));
> >=20
> > It still has this incorrect conversion in it.
>=20
> Sorry I missed that, what's the exact problem with it?

Because the way _BATCH operation is performed, we call it once...

rollback_registered_many() calls it for the first dev queued in the
list.

So it should be net independant.



