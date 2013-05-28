From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 3/3] arp: flush arp cache on IFF_NOARP change
Date: Tue, 28 May 2013 13:30:23 +0200
Message-ID: <1369740623-17601-4-git-send-email-jiri@resnulli.us>
References: <1369740623-17601-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com,
	xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:43626 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947Ab3E1Lai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 07:30:38 -0400
Received: by mail-ee0-f51.google.com with SMTP id e51so4565313eek.38
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 04:30:36 -0700 (PDT)
In-Reply-To: <1369740623-17601-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=C3=A4s <timo.teras@iki.fi>

IFF_NOARP affects what kind of neighbor entries are created
(nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
cache to refresh all entries.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>

v2->v3: shortened notifier_info struct name
---
 net/ipv4/arp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index bf57402..4429b01 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1235,12 +1235,18 @@ static int arp_netdev_event(struct notifier_blo=
ck *this, unsigned long event,
 			    void *ptr)
 {
 	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_change_info *change_info;
=20
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&arp_tbl, dev);
 		rt_cache_flush(dev_net(dev));
 		break;
+	case NETDEV_CHANGE:
+		change_info =3D ptr;
+		if (change_info->flags_changed & IFF_NOARP)
+			neigh_changeaddr(&arp_tbl, dev);
+		break;
 	default:
 		break;
 	}
--=20
1.7.11.7
