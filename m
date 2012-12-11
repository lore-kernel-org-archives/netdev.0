From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 6/7] bna: Firmware update
Date: Tue, 11 Dec 2012 14:24:55 -0800
Message-ID: <1355264696-8927-7-git-send-email-rmody@brocade.com>
References: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39543 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755051Ab2LKWZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:38 -0500
In-Reply-To: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
 -      Added Stats clear counter to the bfi_enet_stats_mac structure and
        ethtool stats
 -      Modified the firmware naming convention to contain the firmware image
        version (3.1.0.0). The new convention is
        <firmware-image>-<firmware-version>.bin The change will enforce loading
        only compatible firmware with this driver and also avoid over-writing
        the old firmware image in-order to load new version driver as the
        firmware names used to be the same.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfi_enet.h     |    1 +
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    1 +
 drivers/net/ethernet/brocade/bna/cna.h          |    4 ++--
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index eef6e1f..7d10e33 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -787,6 +787,7 @@ struct bfi_enet_stats_bpc {
 
 /* MAC Rx Statistics */
 struct bfi_enet_stats_mac {
+	u64 stats_clr_cnt;	/* times this stats cleared */
 	u64 frame_64;		/* both rx and tx counter */
 	u64 frame_65_127;		/* both rx and tx counter */
 	u64 frame_128_255;		/* both rx and tx counter */
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 40e1e84..455b5a2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -102,6 +102,7 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"rx_unmap_q_alloc_failed",
 	"rxbuf_alloc_failed",
 
+	"mac_stats_clr_cnt",
 	"mac_frame_64",
 	"mac_frame_65_127",
 	"mac_frame_128_255",
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 32e8f17..14ca931 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -37,8 +37,8 @@
 
 extern char bfa_version[];
 
-#define	CNA_FW_FILE_CT	"ctfw.bin"
-#define	CNA_FW_FILE_CT2	"ct2fw.bin"
+#define CNA_FW_FILE_CT	"ctfw-3.1.0.0.bin"
+#define CNA_FW_FILE_CT2	"ct2fw-3.1.0.0.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
-- 
1.7.1
