From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: add rcu protection to netdev->ifalias
Date: Wed, 18 May 2011 06:35:11 +0200
Message-ID: <1305693312.6741.58.camel@edumazet-laptop>
References: <1303980967.3360.60.camel@edumazet-laptop>
	 <20110428084337.6b54603e@nehalam>
	 <20110502.152733.48516094.davem@davemloft.net>
	 <1305670692.6741.14.camel@edumazet-laptop>
	 <20110517152503.2f7244f3@nehalam>
	 <1305671956.6741.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38493 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab1EREfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 00:35:18 -0400
Received: by wya21 with SMTP id 21so893039wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 21:35:17 -0700 (PDT)
In-Reply-To: <1305671956.6741.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 00:39 +0200, Eric Dumazet a =C3=A9crit :

> I dont know, if it happens to be too hard, we'll just stick again rtn=
l
> for "ip link show" ;)
>=20
>=20

I believe I'll take this path, its a bit too hard for the moment, and
need several preliminary steps :

It is making sense trying to get rid of rtnl_trylock() hack with more
fine grained locks, and thus lower pressure on RTNL.

Some synchronize_rcu() calls are done whith RTNL held : All processes
hitting rtnl_trylock() have to enter a busy loop, restarting syscall as
long as the RTNL owner is blocked in synchronize_rcu().




