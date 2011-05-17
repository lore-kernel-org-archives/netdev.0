From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: add rcu protection to netdev->ifalias
Date: Wed, 18 May 2011 00:39:16 +0200
Message-ID: <1305671956.6741.25.camel@edumazet-laptop>
References: <1303980967.3360.60.camel@edumazet-laptop>
	 <20110428084337.6b54603e@nehalam>
	 <20110502.152733.48516094.davem@davemloft.net>
	 <1305670692.6741.14.camel@edumazet-laptop>
	 <20110517152503.2f7244f3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56868 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695Ab1EQWjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:39:20 -0400
Received: by wya21 with SMTP id 21so771941wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 15:39:19 -0700 (PDT)
In-Reply-To: <20110517152503.2f7244f3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 15:25 -0700, Stephen Hemminger a =C3=A9crit=
 :

> I am beginning to think the idea of optimizing case of "ip link show"
> running in background with adding/removing network devices is silly.=20
> And switching to RCU leads to all sorts of corner cases where only
> partial data will be read. Is it really worth it?
>=20

Just try "modprobe dummy numdummies=3D1000", and watch load average
raising, because so many processes want to hold RTNL, and the
rtnl_trylock() crazy thing make them spin (restart syscall, and find
RTNL locked again... wooo...)

Some workloads hit RTNL quite hard, and monitoring tools were sometime
frozen for unexpected long times. (before the patch, when we used to
hold RTNL in dump())

I dont know, if it happens to be too hard, we'll just stick again rtnl
for "ip link show" ;)



