From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V16 2/3] Check for vlan ethernet types for 8021.q or 802.1ad
Date: Thu, 15 Oct 2015 10:36:53 -0400
Message-ID: <1444919813-27880-1-git-send-email-thomasfherbert@gmail.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34839 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbJOOhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 10:37:07 -0400
Received: by qgt47 with SMTP id 47so72416979qgt.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 07:37:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 include/linux/if_vlan.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 67ce5bd..ac23521 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -627,6 +627,22 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 
 	return features;
 }
+/**
+ * eth_type_vlan - check for valid vlan ether type.
+ * @ethertype: ether type to check
+ *
+ * Returns true if the ether type is a vlan ether type.
+ */
+static inline bool eth_type_vlan(__be16 ethertype)
+{
+	switch (ethertype) {
+	case (htons(ETH_P_8021Q)):
+	case (htons(ETH_P_8021AD)):
+		return true;
+	default:
+		return false;
+	}
+}
 
 /**
  * compare_vlan_header - Compare two vlan headers
-- 
2.4.3
