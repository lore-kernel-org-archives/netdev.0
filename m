From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 1/7] ieee80211: Fix header->qos_ctl endian issue
Date: Mon, 21 Aug 2006 11:32:31 +0800
Message-ID: <20060821033231.GA4766@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47122 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932545AbWHUDeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:34:25 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jackie Wu <jackie.wu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_crypt_tkip.c |    2 +-
 net/ieee80211/ieee80211_tx.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

5f71dc4d20e5be8004f547d32012fec28d38cff6
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 34dba0b..a61b09e 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -528,7 +528,7 @@ static void michael_mic_hdr(struct sk_bu
 	if (stype & IEEE80211_STYPE_QOS_DATA) {
 		const struct ieee80211_hdr_3addrqos *qoshdr =
 			(struct ieee80211_hdr_3addrqos *)skb->data;
-		hdr[12] = le16_to_cpu(qoshdr->qos_ctl) & IEEE80211_QCTL_TID;
+		hdr[12] = qoshdr->qos_ctl & cpu_to_le16(IEEE80211_QCTL_TID);
 	} else
 		hdr[12] = 0;		/* priority */
 
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index bf04213..f2e6131 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -337,7 +337,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 		hdr_len += 2;
 
 		skb->priority = ieee80211_classify(skb);
-		header.qos_ctl |= skb->priority & IEEE80211_QCTL_TID;
+		header.qos_ctl |= cpu_to_le16(skb->priority & IEEE80211_QCTL_TID);
 	}
 	header.frame_ctl = cpu_to_le16(fc);
 
-- 
1.2.6
