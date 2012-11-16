From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use right lock in __dev_remove_offload
Date: Fri, 16 Nov 2012 10:08:23 -0800
Message-ID: <1353089303.10798.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36903 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2KPSI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:08:27 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2095356pbc.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 10:08:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

offload_base is protected by offload_lock, not ptype_lock

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cf105e8..2705a2a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -513,7 +513,7 @@ void __dev_remove_offload(struct packet_offload *po)
 	struct list_head *head = &offload_base;
 	struct packet_offload *po1;
 
-	spin_lock(&ptype_lock);
+	spin_lock(&offload_lock);
 
 	list_for_each_entry(po1, head, list) {
 		if (po == po1) {
@@ -524,7 +524,7 @@ void __dev_remove_offload(struct packet_offload *po)
 
 	pr_warn("dev_remove_offload: %p not found\n", po);
 out:
-	spin_unlock(&ptype_lock);
+	spin_unlock(&offload_lock);
 }
 EXPORT_SYMBOL(__dev_remove_offload);
 
