From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 01/11] IB/ipoib: Export call to call_netdevice_notifiers and add new private flag
Date: Fri, 14 Sep 2007 16:40:20 -0700
Message-ID: <11898132322950-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46924 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753517AbXINXkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:37 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENg1MR009326
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:42:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENeZSR661404
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:35 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENeYfU008507
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:34 -0400
In-Reply-To: <11898132301664-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monisonlists@gmail.com>

Export the call to raw_notifier_call_chain so modules can send notifications
on netdev events to the netdev_chain.
Add IFF_SLAVE_DETACH to the list of priv_flags for net_device.
This flag is set by a slave that is about to unregisster from the kernel.

Both changes are used in bonding slaves that wish to inform the bonding master
about coming detachment.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 include/linux/if.h |    1 +
 net/core/dev.c     |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 32bf419..b302b22 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -61,6 +61,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_SLAVE_DETACH 0x80		/* slave is about to unregister */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/net/core/dev.c b/net/core/dev.c
index a76021c..5322add 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1148,6 +1148,7 @@ int call_netdevice_notifiers(unsigned long val, void *v)
 {
 	return raw_notifier_call_chain(&netdev_chain, val, v);
 }
+EXPORT_SYMBOL(call_netdevice_notifiers);
 
 /* When > 0 there are consumers of rx skb time stamps */
 static atomic_t netstamp_needed = ATOMIC_INIT(0);
-- 
1.5.2-rc2.GIT

