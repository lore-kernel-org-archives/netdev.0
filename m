From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 14 Nov 2006 20:29:26 -0500
Message-ID: <20061115012921.GF3451@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:58377 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S966613AbWKOBdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 20:33:07 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 0579e303553655245e8a6616bd8b4428b07d63a2:
  Linus Torvalds:
        Merge branch 'for-linus' of git://git.kernel.org/.../drzeus/mmc

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Zhu Yi:
      ieee80211: Fix kernel panic when QoS is enabled

 net/ieee80211/ieee80211_tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

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
John W. Linville
linville@tuxdriver.com
