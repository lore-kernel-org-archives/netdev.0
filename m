From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND NET-NEXT PATCH 17/20] net: add netif_napi_del function to
	allow for removal of napistructs
Date: Tue, 08 Jul 2008 15:13:05 -0700
Message-ID: <20080708221219.1518.92921.stgit@localhost.localdomain>
References: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9724 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750AbYGHWNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:13:10 -0400
In-Reply-To: <20080708220046.1518.88457.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adds netif_napi_del function which is used to remove the napi struct from
the netdev napi_list in cases where CONFIG_NETPOLL was enabled.
The motivation for adding this is to handle the case in which the number of
queues on a device changes due to a configuration change.  Previously the
napi structs for each queue would be left in the list until the netdev was
freed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e009c6f..60cf72e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -832,6 +832,19 @@ static inline void netif_napi_add(struct net_device *dev,
 	set_bit(NAPI_STATE_SCHED, &napi->state);
 }
 
+/**
+ *  netif_napi_del - remove a napi context
+ *  @napi: napi context
+ *
+ *  netif_napi_del() removes a napi context from the network device napi list
+ */
+static inline void netif_napi_del(struct napi_struct *napi)
+{
+#ifdef CONFIG_NETPOLL
+	list_del(&napi->dev_list);
+#endif
+}
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */

