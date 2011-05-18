From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: make sure rtnl is held in
 rtnl_fill_ifinfo()
Date: Wed, 18 May 2011 18:02:39 +0200
Message-ID: <1305734559.2991.50.camel@edumazet-laptop>
References: <1305711303.2983.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58280 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757084Ab1ERQCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 12:02:44 -0400
Received: by fxm17 with SMTP id 17so1319958fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 09:02:43 -0700 (PDT)
In-Reply-To: <1305711303.2983.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 11:35 +0200, Eric Dumazet a =C3=A9crit :
> Commit e67f88dd12f610 (net: dont hold rtnl mutex during netlink dump
> callbacks) added a problem in rtnl_fill_ifinfo() not being always cal=
led
> with RTNL held, which is racy.
>=20
> 1) This patch extends rtnl_mutex helper functions so that :
>=20
> rtnl_lock() is able to BUG_ON() if recursively called.
> [This was only provided if LOCKDEP was on]
>=20
> rtnl_is_locked() is able to check if current thread owns rtnl_mutex
> [ASSERT_RTNL() gets this added feature too]
>=20
> 2) Add one ASSERT_RTNL() in rtnl_fill_ifinfo()
>=20
> 3) Make sure rtnl is held in rtnl_dump_ifinfo()
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> --

Hmm, please disregard, there is a lock depency problem here

netlink_dump() does a mutex_lock(nlk->cb_mutex)
So if we try to lock rtnl_mutex later in rtnl_dump_ifinfo(), we can
deadlock with another task doing the reverse.

(first lock rtnl_mutex, then nlk->cb_mutex)




