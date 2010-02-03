From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: use helpers to access mc list V2
Date: Wed, 3 Feb 2010 13:59:43 +0100
Message-ID: <20100203125942.GA9266@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257Ab0BCM7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 07:59:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the similar helpers as those already done for uc list.
However multicast lists are no list_head lists but "mademanually". The three
macros added by this patch will make the transition of mc_list to list_head
smooth in two steps:

1) convert all drivers to use these macros (with the original iterator of type
   "struct dev_mc_list")
2) once all drivers are converted, convert list type and iterators to "struct
   netdev_hw_addr" in one patch.

>From now on, drivers can (and should) use "netdev_for_each_mc_addr" to iterate
over the addresses with iterator of type "struct netdev_hw_addr". Also macros
"netdev_mc_count" and "netdev_mc_empty" to read list's length. This is the state
which should be reached in all drivers.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 93a32a5..3f1c4a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -268,6 +268,12 @@ struct netdev_hw_addr_list {
 #define netdev_for_each_uc_addr(ha, dev) \
 	list_for_each_entry(ha, &dev->uc.list, list)
 
+#define netdev_mc_count(dev) ((dev)->mc_count)
+#define netdev_mc_empty(dev) (netdev_mc_count(dev) == 0)
+
+#define netdev_for_each_mc_addr(mclist, dev) \
+	for (mclist = dev->mc_list; mclist; mclist = mclist->next)
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
-- 
1.6.6

