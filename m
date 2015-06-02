From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V10 2/4] General check for vlan ethernet types
Date: Tue,  2 Jun 2015 13:50:42 -0400
Message-ID: <1433267444-26025-3-git-send-email-thomasfherbert@gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:34757 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759547AbbFBRvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 13:51:13 -0400
Received: by yhom41 with SMTP id m41so43427224yho.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 10:51:13 -0700 (PDT)
In-Reply-To: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a function to check for vlan ethernet types. There is a
use case in openvswitch and it should be useful elsewhere.

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
