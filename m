From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network stack timer hacks for power saving
Date: Tue, 19 May 2009 11:04:08 +0200
Message-ID: <4A127608.5020109@cosmosbay.com>
References: <1F18D6510CF0474A8C9500565A7E41A20544D923FF@NOK-EUMSG-02.mgdnok.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tero.Kristo@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59852 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbZESJEQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 05:04:16 -0400
In-Reply-To: <1F18D6510CF0474A8C9500565A7E41A20544D923FF@NOK-EUMSG-02.mgdnok.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tero.Kristo@nokia.com a =E9crit :
> Hi,
>=20
> I have been looking at network stack timer optimization for=20
> power saving in embedded ARM environment, basically trying to=20
> avoid as many wakeups as possible. I have changed several=20
> timers in the network stack into deferred ones, i.e. they do=20
> not wake up the device from low power modes but instead they=20
> are deferred until next wakeup from some other source, like=20
> another (non-deferred) timer or some I/O. Attached a patch=20
> about the changes I've done, is something like this safe to do?
>=20
> -Tero

Hi Tero


When tcp communications are active, we setup a timer for *every* frame
we receive or we send. These timers wont be deferrable anyway.

delaying one wakeup every 60 seconds (if I take your net/ipv4/route.c c=
hange)
wont change that much power savings, or did I missed something ?

On big routers, we need to set ip_rt_gc_interval from 60 seconds to one=
 second,
in order to perform an effective garbage collection.

So, if we use a deferred timer and :

schedule_delayed_work(&expires_work, HZ);

How many times worker will be started every minute ?


