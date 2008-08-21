From: adobriyan@gmail.com
Subject: [PATCH 2/6] netns brnetfilter: cleanup during table unregister
Date: Fri, 22 Aug 2008 02:21:26 +0400
Message-ID: <20080821222126.GP31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:45589 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbYHUWUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:20:06 -0400
Received: by yx-out-2324.google.com with SMTP id 8so105704yxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:20:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far it wasn't needed, because modules were pinned just right to prevent ebtables from
unloading when cleanup was necessary.

ebt_unregster_table() is called during netns stop now, so...

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/netfilter/ebtables.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1262,6 +1262,8 @@ void ebt_unregister_table(struct ebt_table *table)
 	mutex_lock(&ebt_mutex);
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
+			  ebt_cleanup_entry, NULL);
 	vfree(table->private->entries);
 	if (table->private->chainstack) {
 		for_each_possible_cpu(i)
-- 
1.5.6.3


