From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: add link-local, sit and loopback address with INFINITY_LIFE_TIME
Date: Wed, 8 Jan 2014 15:43:22 +0100
Message-ID: <20140108144322.GJ9007@order.stressinduktion.org>
References: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	damien.wyart@gmail.com, yasushi.asano@jp.fujitsu.com
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48448 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664AbaAHOnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:43:23 -0500
Content-Disposition: inline
In-Reply-To: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the past the IFA_PERMANENT flag indicated, that the valid and prefer=
red
lifetime where ignored. Since change fad8da3e085ddf ("ipv6 addrconf: fi=
x
preferred lifetime state-changing behavior while valid_lft is infinity"=
)
we honour at least the preferred lifetime on those addresses. As such
the valid lifetime gets recalculated and updated to 0.

If loopback address is added manually this problem does not occur.
Also if NetworkManager manages IPv6, those addresses will get added via
inet6_rtm_newaddr and thus will have a correct lifetime, too.

Reported-by: Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com>
Reported-by: Damien Wyart <damien.wyart@gmail.com>
=46ixes: fad8da3e085ddf ("ipv6 addrconf: fix preferred lifetime state-c=
hanging behavior while valid_lft is infinity")
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I hope there will be another pull request to Linus before 3.13 (I think
there will be an upcoming -rc8 this Sunday?).

 net/ipv6/addrconf.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 31f75ea..01263a1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2528,7 +2528,8 @@ static void add_addr(struct inet6_dev *idev, cons=
t struct in6_addr *addr,
 	struct inet6_ifaddr *ifp;
=20
 	ifp =3D ipv6_add_addr(idev, addr, NULL, plen,
-			    scope, IFA_F_PERMANENT, 0, 0);
+			    scope, IFA_F_PERMANENT,
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &=3D ~IFA_F_TENTATIVE;
@@ -2656,7 +2657,8 @@ static void addrconf_add_linklocal(struct inet6_d=
ev *idev, const struct in6_addr
 #endif
=20
=20
-	ifp =3D ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags, 0, =
0);
+	ifp =3D ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
--=20
1.8.4.2
