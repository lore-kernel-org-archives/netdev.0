From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/7] be2net: Do not call get_die_temperature cmd for VF
Date: Tue, 6 Aug 2013 09:27:16 +0530
Message-ID: <1375761441-22343-3-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56553 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3HFDyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:54:16 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This is a chip wide value and the PFs already report it.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3df1503..834f77b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4143,7 +4143,8 @@ static void be_worker(struct work_struct *work)
 			be_cmd_get_stats(adapter, &adapter->stats_cmd);
 	}
 
-	if (MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
+	if (be_physfn(adapter) &&
+	    MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
 		be_cmd_get_die_temperature(adapter);
 
 	for_all_rx_queues(adapter, rxo, i) {
-- 
1.7.1
