From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 2/6] arp: flush arp cache on IFF_NOARP change
Date: Mon, 27 May 2013 14:16:12 +0300
Message-ID: <1369653376-4731-3-git-send-email-timo.teras@iki.fi>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:54055 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672Ab3E0LOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:14:43 -0400
Received: by mail-ee0-f44.google.com with SMTP id b57so3939763eek.3
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:14:42 -0700 (PDT)
In-Reply-To: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_NOARP affects what kind of neighbor entries are created
(nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
cache to refresh all entries.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/ipv4/arp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 247ec19..0a15fb7 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1241,6 +1241,10 @@ static int arp_netdev_event(struct notifier_bloc=
k *this, unsigned long event,
 		neigh_changeaddr(&arp_tbl, dev);
 		rt_cache_flush(dev_net(dev));
 		break;
+	case NETDEV_CHANGE:
+		if (dev->flags_changed & IFF_NOARP)
+			neigh_changeaddr(&arp_tbl, dev);
+		break;
 	default:
 		break;
 	}
--=20
1.8.2.3
