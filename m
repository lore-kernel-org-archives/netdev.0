From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH 3/3] dcb: Add stub routines for !CONFIG_DCB
Date: Thu, 06 Oct 2011 11:52:44 -0700
Message-ID: <20111006185243.2781.67932.stgit@jf-dev1-dcblab>
References: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17763 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759028Ab1JFTBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 15:01:45 -0400
In-Reply-To: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid ifdefs in the other code that supports DCB notifiers
add stub routines. This method seems popular in other net code
for example 8021Q.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbevent.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/dcbevent.h b/include/net/dcbevent.h
index bc1e7ef..443626e 100644
--- a/include/net/dcbevent.h
+++ b/include/net/dcbevent.h
@@ -24,8 +24,26 @@ enum dcbevent_notif_type {
 	DCB_APP_EVENT = 1,
 };
 
+#ifdef CONFIG_DCB
 extern int register_dcbevent_notifier(struct notifier_block *nb);
 extern int unregister_dcbevent_notifier(struct notifier_block *nb);
 extern int call_dcbevent_notifiers(unsigned long val, void *v);
+#else
+static inline int
+register_dcbevent_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int unregister_dcbevent_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int call_dcbevent_notifiers(unsigned long val, void *v)
+{
+	return 0;
+}
+#endif /* CONFIG_DCB */
 
 #endif
