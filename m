From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: dont hold rtnl mutex during netlink
 dump callbacks
Date: Thu, 28 Apr 2011 17:53:50 +0200
Message-ID: <1304006030.3360.70.camel@edumazet-laptop>
References: <1303980967.3360.60.camel@edumazet-laptop>
	 <20110428084337.6b54603e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43537 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758913Ab1D1Pxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 11:53:55 -0400
Received: by wwa36 with SMTP id 36so3280313wwa.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 08:53:54 -0700 (PDT)
In-Reply-To: <20110428084337.6b54603e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 avril 2011 =C3=A0 08:43 -0700, Stephen Hemminger a =C3=A9cr=
it :
> On Thu, 28 Apr 2011 10:56:07 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Four years ago, Patrick made a change to hold rtnl mutex during net=
link
> > dump callbacks.
> >=20
> > I believe it was a wrong move. This slows down concurrent dumps, ma=
king
> > good old /proc/net/ files faster than rtnetlink in some situations.
> >=20
> > This occurred to me because one "ip link show dev ..." was _very_ s=
low
> > on a workload adding/removing network devices in background.
> >=20
> > All dump callbacks are able to use RCU locking now, so this patch d=
oes
> > roughly a revert of commits :
> >=20
> > 1c2d670f366 : [RTNETLINK]: Hold rtnl_mutex during netlink dump call=
backs
> > 6313c1e0992 : [RTNETLINK]: Remove unnecessary locking in dump callb=
acks
> >=20
> > This let writers fight for rtnl mutex and readers going full speed.
> >=20
> > It also takes care of phonet : phonet_route_get() is now called fro=
m rcu
> > read section. I renamed it to phonet_route_get_rcu()
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Thanks for reviewing Stephen=20


