From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V17 2/3] Check for vlan ethernet types for 8021.q or 802.1ad
Date: Sun, 25 Oct 2015 20:11:25 -0400
Message-ID: <1445818286-4870-3-git-send-email-thomasfherbert@gmail.com>
References: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:32944 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbJZANg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 20:13:36 -0400
Received: by qgeo38 with SMTP id o38so108357653qge.0
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 17:13:35 -0700 (PDT)
In-Reply-To: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 include/linux/if_vlan.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 67ce5bd..d2494b5 100644
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
+	case htons(ETH_P_8021Q):
+	case htons(ETH_P_8021AD):
+		return true;
+	default:
+		return false;
+	}
+}
 
 /**
  * compare_vlan_header - Compare two vlan headers
-- 
2.4.3
