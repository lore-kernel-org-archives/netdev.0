From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V15 2/3] Check for vlan ethernet types for 8021.q or 802.1ad
Date: Sat, 10 Oct 2015 19:40:32 -0400
Message-ID: <1444520433-1958-3-git-send-email-thomasfherbert@gmail.com>
References: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37489 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbJJXlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 19:41:01 -0400
Received: by wijq8 with SMTP id q8so11535176wij.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 16:41:00 -0700 (PDT)
In-Reply-To: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 include/linux/if_vlan.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 67ce5bd..88d1be4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -627,6 +627,23 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 
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
+		return true;
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
