From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv4: do not abuse GFP_ATOMIC in
 inet_netconf_notify_devconf()
Date: Fri, 8 Jul 2016 09:54:08 +0200
Message-ID: <577F5C20.4050201@6wind.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Masashi Honma <masashi.honma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38400 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057AbcGHHyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 03:54:12 -0400
Received: by mail-wm0-f49.google.com with SMTP id n127so7441807wme.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 00:54:11 -0700 (PDT)
In-Reply-To: <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/07/2016 05:18, Eric Dumazet a =C3=A9crit :
> From: Eric Dumazet <edumazet@google.com>
>=20
> inet_forward_change() runs with RTNL held.
> We are allowed to sleep if required.
>=20
> If we use __in_dev_get_rtnl() instead of __in_dev_get_rcu(),
> we no longer have to use GFP_ATOMIC allocations in
> inet_netconf_notify_devconf(), meaning we are less likely to miss
> notifications under memory pressure, and wont touch precious memory
> reserves either and risk dropping incoming packets.
>=20
> inet_netconf_get_devconf() can also use GFP_KERNEL allocation.
>=20
> Fixes: edc9e748934c ("rtnl/ipv4: use netconf msg to advertise forward=
ing status")
> Fixes: 9e5511106f99 ("rtnl/ipv4: add support of RTM_GETNETCONF")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Nice catch, thank you!
