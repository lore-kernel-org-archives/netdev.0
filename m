From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ieee80211: Fix kernel panic when QoS is enabled
Date: Mon, 13 Nov 2006 11:32:50 +0800
Message-ID: <20061113033250.GA16740@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9363 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1753844AbWKMDfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Nov 2006 22:35:14 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 802.11 header length is affected by the wireless mode (WDS or not) and
type (QoS or not). We should use the variable hdr_len instead of the
hard coded IEEE80211_3ADDR_LEN, otherwise we may touch invalid memory.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

97f244c8efd9a30f0e63e71709ee0142e85307f6
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index ae25449..854fc13 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -390,7 +390,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 		 * this stack is providing the full 802.11 header, one will
 		 * eventually be affixed to this fragment -- so we must account
 		 * for it when determining the amount of payload space. */
-		bytes_per_frag = frag_size - IEEE80211_3ADDR_LEN;
+		bytes_per_frag = frag_size - hdr_len;
 		if (ieee->config &
 		    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
 			bytes_per_frag -= IEEE80211_FCS_LEN;
@@ -412,7 +412,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	} else {
 		nr_frags = 1;
 		bytes_per_frag = bytes_last_frag = bytes;
-		frag_size = bytes + IEEE80211_3ADDR_LEN;
+		frag_size = bytes + hdr_len;
 	}
 
 	rts_required = (frag_size > ieee->rts
-- 
1.2.6
