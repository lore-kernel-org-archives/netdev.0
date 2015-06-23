From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V11 2/3] Check for vlan ethernet types for 8021.q or 802.1ad
Date: Tue, 23 Jun 2015 14:26:29 -0400
Message-ID: <1435083990-12986-3-git-send-email-thomasfherbert@gmail.com>
References: <1435083990-12986-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:33147 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbbFWSaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 14:30:00 -0400
Received: by yhpn97 with SMTP id n97so7307727yhp.0
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 11:30:00 -0700 (PDT)
In-Reply-To: <1435083990-12986-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 include/linux/if_vlan.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 920e445..3713454 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -627,5 +627,14 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 
 	return features;
 }
+/**
+ * Check for legal valid vlan ether type.
+ */
+static inline bool eth_type_vlan(__be16 ethertype)
+{
+	if (ethertype == htons(ETH_P_8021Q) || ethertype == htons(ETH_P_8021AD))
+		return true;
+	return false;
+}
 
 #endif /* !(_LINUX_IF_VLAN_H_) */
-- 
2.1.0
