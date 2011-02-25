From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/7] net: handle addr_type of 0 properly
Date: Fri, 25 Feb 2011 16:45:15 +0100
Message-ID: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57594 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755494Ab1BYPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addr_type of 0 means that the type should be adopted from from_dev and
not from __hw_addr_del_multiple(). Unfortunately it isn't so and
addr_type will always be considered. Fix this by implementing the
considered and documented behavior.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/core/dev_addr_lists.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 508f9c1..133fd22 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -144,7 +144,7 @@ void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
 
 	list_for_each_entry(ha, &from_list->list, list) {
 		type = addr_type ? addr_type : ha->type;
-		__hw_addr_del(to_list, ha->addr, addr_len, addr_type);
+		__hw_addr_del(to_list, ha->addr, addr_len, type);
 	}
 }
 EXPORT_SYMBOL(__hw_addr_del_multiple);
-- 
1.7.2.3

