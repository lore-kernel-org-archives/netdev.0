From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH v2 2/4] netxen: lower NAPI weight
Date: Fri, 23 Aug 2013 15:41:09 +0200
Message-ID: <52176675.3060202@redhat.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-3-git-send-email-mschmidt@redhat.com> <521503E5.1080003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755507Ab3HWNlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 09:41:15 -0400
In-Reply-To: <521503E5.1080003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
netif_napi_add() produces an error message if a NAPI poll weight
greater than 64 is requested.

Use the standard NAPI weight.

v2: proper reference to the related commit

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h      | 1 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 3fe09ab..32675e1 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -1171,7 +1171,6 @@ typedef struct {
 
 #define NETXEN_DB_MAPSIZE_BYTES    	0x1000
 
-#define NETXEN_NETDEV_WEIGHT 128
 #define NETXEN_ADAPTER_UP_MAGIC 777
 #define NETXEN_NIC_PEG_TUNE 0
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 1046e94..cbd75f9 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -197,7 +197,7 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		netif_napi_add(netdev, &sds_ring->napi,
-				netxen_nic_poll, NETXEN_NETDEV_WEIGHT);
+				netxen_nic_poll, NAPI_POLL_WEIGHT);
 	}
 
 	return 0;
-- 
1.8.3.1
