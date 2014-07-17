From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 11/14] be2net: use be_max_vfs() macro to access max-vfs
Date: Thu, 17 Jul 2014 16:20:29 +0530
Message-ID: <1405594232-30818-12-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9072 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810AbaGQKsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:41 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

max-vfs value must be accessed via the macro be_max_vfs(adapter).
The earlier patch "create optimal number of queues on SR-IOV config"
by mistake, did not use this macro. This patch fixes it.

fixes: bec84e6b ("be2net: create optimal number of queues on SR-IOV config")
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b354b28..c622e42 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3312,7 +3312,7 @@ static void BEx_get_resources(struct be_adapter *adapter,
 	res->max_rx_qs = res->max_rss_qs + 1;
 
 	if (be_physfn(adapter))
-		res->max_evt_qs = (res->max_vfs > 0) ?
+		res->max_evt_qs = (be_max_vfs(adapter) > 0) ?
 					BE3_SRIOV_MAX_EVT_QS : BE3_MAX_EVT_QS;
 	else
 		res->max_evt_qs = 1;
-- 
1.7.1
