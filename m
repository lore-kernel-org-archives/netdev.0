From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 13:51:04 +0100
Message-ID: <1352897464-832-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44417 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422711Ab2KNMvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 07:51:10 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so230567eek.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 04:51:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
sets this. Correct the check to behave properly on addr removal.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev_addr_lists.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 87cc17d..b079c7b 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -319,7 +319,8 @@ int dev_addr_del(struct net_device *dev, const unsigned char *addr,
 	 */
 	ha = list_first_entry(&dev->dev_addrs.list,
 			      struct netdev_hw_addr, list);
-	if (ha->addr == dev->dev_addr && ha->refcount == 1)
+	if (!memcmp(ha->addr, addr, dev->addr_len) &&
+	    ha->type == addr_type && ha->refcount == 1)
 		return -ENOENT;
 
 	err = __hw_addr_del(&dev->dev_addrs, addr, dev->addr_len,
-- 
1.8.0
