From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: use list_first_entry macro
Date: Wed, 24 Feb 2010 16:01:38 -0800
Message-ID: <20100224160138.3a8de8de@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60334 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758589Ab0BYABy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:01:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use list_first_entry macro; no longer any need to use 
'next' directly in list to find first entry.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2010-02-24 15:14:47.502112037 -0800
+++ b/net/core/dev.c	2010-02-24 15:15:45.201861020 -0800
@@ -3018,7 +3018,7 @@ static void net_rx_action(struct softirq
 		 * entries to the tail of this list, and only ->poll()
 		 * calls can remove this head entry from the list.
 		 */
-		n = list_entry(list->next, struct napi_struct, poll_list);
+		n = list_first_entry(list, struct napi_struct, poll_list);
 
 		have = netpoll_poll_lock(n);
 
@@ -4882,7 +4882,7 @@ static void rollback_registered_many(str
 	}
 
 	/* Process any work delayed until the end of the batch */
-	dev = list_entry(head->next, struct net_device, unreg_list);
+	dev = list_first_entry(head, struct net_device, unreg_list);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 
 	synchronize_net();
@@ -5268,7 +5268,7 @@ void netdev_run_todo(void)
 
 	while (!list_empty(&list)) {
 		struct net_device *dev
-			= list_entry(list.next, struct net_device, todo_list);
+			= list_first_entry(&list, struct net_device, todo_list);
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
