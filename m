From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 03/10] be2net: receive pkts with L3, L4 errors on VFs
Date: Mon,  4 May 2015 02:47:15 -0400
Message-ID: <1430722042-26449-4-git-send-email-sathya.perla@emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752182AbbEDG7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:34 -0400
In-Reply-To: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

Currently pkts with L3 or L4 errors received on PFs are not dropped
by the adapter, but instead sent to the stack. This helps the network stack
to better reflect error statistics. This was not being done on BE3 VFs.
This patch fixes this for BE3 VFs.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 85bc7f0..f426a15 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3657,7 +3657,7 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 
 	/* If a FW profile exists, then cap_flags are updated */
 	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-		    BE_IF_FLAGS_MULTICAST;
+		    BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
 
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (!BE3_chip(adapter)) {
-- 
2.2.0
