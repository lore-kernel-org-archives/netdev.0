From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V19 2/3] Check for vlan ethernet types for 8021.q or 802.1ad
Date: Fri, 30 Oct 2015 13:08:21 -0400
Message-ID: <1446224902-21246-3-git-send-email-thomasfherbert@gmail.com>
References: <1446224902-21246-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:32866 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759037AbbJ3RIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 13:08:51 -0400
Received: by ykdr3 with SMTP id r3so6784933ykd.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 10:08:51 -0700 (PDT)
In-Reply-To: <1446224902-21246-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to simplify using double tagged vlans. This function allows all
valid vlan ethertypes to be checked in a single function call.

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
