From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipip: get rid of ipip_lock
Date: Wed, 15 Sep 2010 22:49:37 +0200
Message-ID: <1284583777.2462.33.camel@edumazet-laptop>
References: <1284571676.2462.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35180 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab0IOUun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 16:50:43 -0400
Received: by wwd20 with SMTP id 20so22wwd.1
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 13:50:40 -0700 (PDT)
In-Reply-To: <1284571676.2462.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 19:28 +0200, Eric Dumazet a =C3=A9=
crit :
> As RTNL is held while doing tunnels inserts and deletes, we can remov=
e
> ipip_lock spinlock. My initial RCU conversion was conservative and
> converted the rwlock to spinlock, with no RTNL requirement.
>=20
> Use appropriate rcu annotations and modern lockdep checks as well.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

While doing ip_gre conversion, I realize I should define a new helper

/**
 * rtnl_dereference - rcu_dereference with debug checking
 * @p: The pointer to read, prior to dereferencing
 *
 * Do an rcu_dereference(p), but check caller holds RTNL
 */
#define rtnl_dereference(p)					\
	rcu_dereference_check(p, lockdep_rtnl_is_held())



I'll submit a patch serie :

1/3) net: add rtnl_dereference
2/3) ipip: get rid of ipip_lock
3/3) gre: get rid of ipgre_lock

Thanks


