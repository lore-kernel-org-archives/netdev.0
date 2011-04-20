From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next-2.6] can: replace spinlocks with mutexes
Date: Wed, 20 Apr 2011 17:39:14 +0200
Message-ID: <1303313954.3186.117.camel@edumazet-laptop>
References: <4DAEFC55.2010500@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41053 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab1DTPjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 11:39:22 -0400
Received: by wya21 with SMTP id 21so716539wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 08:39:21 -0700 (PDT)
In-Reply-To: <4DAEFC55.2010500@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 17:31 +0200, Oliver Hartkopp a =C3=A9c=
rit :
> This patch removes spinlocks for the CAN netdevice specific receive l=
ists.
> The RCU-based receive lists can be modified from process context or f=
rom the
> netdevice notifier call. As both might sleep we can safely replace th=
e
> spinlocks with mutexes.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> ---

But... why ?

A spinlock is faster/smaller than a mutex.

Maybe you wanted to _remove_ spinlock, since/if writer hold RTNL and
doesnt need to exclude another writer(s) ?

Note : I did not check the RTNL assertion, you might add appropriate
ASSERT_RTNL() calls just to be 100% safe.



