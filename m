From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] neigh: allow admin to set NUD_STALE
Date: Wed, 27 Jul 2016 09:56:50 +0300
Message-ID: <1469602610-6934-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38804 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751723AbcG0G5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 02:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Admin should be able to set any state. Currently, this fails
when lladdr is not changed and state is changed from
NUD_CONNECTED to NUD_STALE:

ip neigh add 192.168.8.1 lladdr 00:11:22:33:44:55 nud perm dev wlan0
ip neigh show to 192.168.8.1
192.168.8.1 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
ip neigh change 192.168.8.1 lladdr 00:11:22:33:44:55 nud stale dev wlan0
ip neigh show to 192.168.8.1
192.168.8.1 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT

Problem may be from 2.1.X days.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/neighbour.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cf26e04c4..2ae929f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1148,7 +1148,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			} else
 				goto out;
 		} else {
-			if (lladdr == neigh->ha && new == NUD_STALE)
+			if (lladdr == neigh->ha && new == NUD_STALE &&
+			    !(flags & NEIGH_UPDATE_F_ADMIN))
 				new = old;
 		}
 	}
-- 
1.9.3
