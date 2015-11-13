From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 2/2] be2net: replace hardcoded values with existing define
Date: Fri, 13 Nov 2015 11:36:58 +0100
Message-ID: <1447411018-11745-2-git-send-email-ivecera@redhat.com>
References: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Cc: sriharsha.basavapatna@avagotech.com, sathya.perla@avagotech.com,
	ajit.khaparde@avagotech.com, padmanabh.ratnakar@avagotech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932956AbbKMKhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 05:37:03 -0500
In-Reply-To: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 3 ++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 3d8c6c1..2362304 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1116,7 +1116,8 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 		return 0;
 
 	status = be_cmd_rss_config(adapter, adapter->rss_info.rsstable,
-				   rss_flags, 128, adapter->rss_info.rss_hkey);
+				   rss_flags, RSS_INDIR_TABLE_LEN,
+				   adapter->rss_info.rss_hkey);
 	if (!status)
 		adapter->rss_info.rss_flags = rss_flags;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index eb48a97..b6ad029 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3518,7 +3518,7 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 
 	netdev_rss_key_fill(rss_key, RSS_HASH_KEY_LEN);
 	rc = be_cmd_rss_config(adapter, rss->rsstable, rss->rss_flags,
-			       128, rss_key);
+			       RSS_INDIR_TABLE_LEN, rss_key);
 	if (rc) {
 		rss->rss_flags = RSS_ENABLE_NONE;
 		return rc;
-- 
2.4.10
