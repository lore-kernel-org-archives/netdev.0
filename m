From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: make all team port device link events urgent
Date: Tue, 11 Jun 2013 23:09:29 +0200
Message-ID: <1370984969-15797-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com,
	bhutchings@solarflare.com, tj@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:42085 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab3FKVJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 17:09:39 -0400
Received: by mail-ea0-f169.google.com with SMTP id h15so6628487eak.0
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 14:09:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>

Since team functionality relies heavily on userspace daemon, we need to
deliver event to userspace via Netlink as quick as possible. So make all
team port device link events urgent.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/link_watch.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 8f82a5c..9c3a839 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -92,6 +92,9 @@ static bool linkwatch_urgent_event(struct net_device *dev)
 	if (dev->ifindex != dev->iflink)
 		return true;
 
+	if (dev->priv_flags & IFF_TEAM_PORT)
+		return true;
+
 	return netif_carrier_ok(dev) &&	qdisc_tx_changing(dev);
 }
 
-- 
1.8.1.4
