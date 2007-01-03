From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 2 Jan 2007 21:41:24 -0500
Message-ID: <20070103024117.GB5661@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4278 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbXACDCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 22:02:52 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 669df1b478803f49a356528d290af7bf442eb3be:
  Linus Torvalds (1):
        Linux 2.6.20-rc3

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Zhu Yi (2):
      ieee80211: WLAN_GET_SEQ_SEQ fix (select correct region)
      ipw2100: Fix dropping fragmented small packet problem

 drivers/net/wireless/ipw2100.c |    2 +-
 include/net/ieee80211.h        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 0e94fbb..b85857a 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -2664,7 +2664,7 @@ static void __ipw2100_rx_process(struct ipw2100_priv *priv)
 				break;
 			}
 #endif
-			if (stats.len < sizeof(u->rx_data.header))
+			if (stats.len < sizeof(struct ieee80211_hdr_3addr))
 				break;
 			switch (WLAN_FC_GET_TYPE(u->rx_data.header.frame_ctl)) {
 			case IEEE80211_FTYPE_MGMT:
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index e6af381..e02d85f 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -218,7 +218,7 @@ struct ieee80211_snap_hdr {
 #define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
 
 #define WLAN_GET_SEQ_FRAG(seq) ((seq) & IEEE80211_SCTL_FRAG)
-#define WLAN_GET_SEQ_SEQ(seq)  ((seq) & IEEE80211_SCTL_SEQ)
+#define WLAN_GET_SEQ_SEQ(seq)  (((seq) & IEEE80211_SCTL_SEQ) >> 4)
 
 /* Authentication algorithms */
 #define WLAN_AUTH_OPEN 0
-- 
John W. Linville
linville@tuxdriver.com
