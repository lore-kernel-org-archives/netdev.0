From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] arp: flush arp cache on IFF_NOARP change
Date: Tue, 28 May 2013 10:10:55 +0200
Message-ID: <1369728655-26649-4-git-send-email-jiri@resnulli.us>
References: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:57539 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933368Ab3E1ILI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:11:08 -0400
Received: by mail-wi0-f177.google.com with SMTP id hr14so2200060wib.10
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:11:07 -0700 (PDT)
In-Reply-To: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=C3=A4s <timo.teras@iki.fi>

IFF_NOARP affects what kind of neighbor entries are created
(nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
cache to refresh all entries.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/arp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b455213..8c8eb40 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1235,12 +1235,18 @@ static int arp_netdev_event(struct notifier_blo=
ck *this, unsigned long event,
 			    void *ptr)
 {
 	struct net_device *dev =3D get_netdevice_notifier_info_dev(ptr);
+	struct netdevice_notifier_change_info *change_info;
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
