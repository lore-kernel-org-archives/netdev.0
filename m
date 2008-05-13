From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Tue, 13 May 2008 10:04:37 +0200
Message-ID: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:30917 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754739AbYEMIEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 04:04:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed that ethtool -S didn't display tx-xxx-frames correctly.
Fix it and a few others while I am there. Strangely, the
rx-jumbo-frames counter still counts pkgs even though I think
there isn't any packtes above 1518.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

Havn't seen this go in or ACK/NACK. Resending.

 drivers/net/ucc_geth_ethtool.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index a995a3a..0eddf50 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -60,7 +60,6 @@ static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-broadcast-frames",
 	"stats-counter-carry",
 	"stats-counter-mask",
-	"rx-dropped-frames",
 };
 
 static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
@@ -73,6 +72,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-frames-ok",
 	"tx-excessive-differ-frames",
 	"tx-256-511-frames",
+	"tx-512-1023-frames",
 	"tx-1024-1518-frames",
 	"tx-jumbo-frames",
 };
@@ -101,7 +101,6 @@ static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-vlan-removed",
 	"rx-vlan-replaced",
 	"rx-vlan-inserted",
-	"rx-ip-checksum-errors",
 };
 
 #define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
-- 
1.5.5.1

