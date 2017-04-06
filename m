From: Colin King <colin.king@canonical.com>
Subject: [PATCH][-next] nfp: don't dereference a null nn->eth_port to print a warning
Date: Thu,  6 Apr 2017 13:54:35 +0100
Message-ID: <20170406125435.18898-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56738 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932347AbdDFMyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:54:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

On the case where nn->eth_port is null the warning message
is printing the port by dereferencing this null pointer.
Remove the deference to avoid a crash when printing the
warning message.

Detected by CoverityScan, CID#1426198 ("Dereference after null check")

Fixes: ce22f5a2cbe3c627 ("nfp: separate high level and low level NSP headers")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 3e1f97e88710..4c6863a072d3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -495,8 +495,7 @@ static void nfp_net_refresh_netdevs(struct work_struct *work)
 
 	list_for_each_entry_safe(nn, next, &pf->ports, port_list) {
 		if (!nn->eth_port) {
-			nfp_warn(pf->cpp, "Warning: port %d not present after reconfig\n",
-				 nn->eth_port->eth_index);
+			nfp_warn(pf->cpp, "Warning: port not present after reconfig\n");
 			continue;
 		}
 		if (!nn->eth_port->override_changed)
-- 
2.11.0
