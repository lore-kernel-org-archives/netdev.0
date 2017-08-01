From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 4/7] nfp: Initialize RX and TX ring 64-bit stats seqcounts
Date: Tue,  1 Aug 2017 12:11:09 -0700
Message-ID: <20170801191113.8754-5-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Simon Horman <simon.horman@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com (open list:NETRONOME ETHERNET DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that.

Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 18750ff0ede6..4631ca8b8eb2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -513,6 +513,7 @@ nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring,
 	tx_ring->idx = idx;
 	tx_ring->r_vec = r_vec;
 	tx_ring->is_xdp = is_xdp;
+	u64_stats_init(&tx_ring->r_vec->tx_sync);
 
 	tx_ring->qcidx = tx_ring->idx * nn->stride_tx;
 	tx_ring->qcp_q = nn->tx_bar + NFP_QCP_QUEUE_OFF(tx_ring->qcidx);
@@ -532,6 +533,7 @@ nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring,
 
 	rx_ring->idx = idx;
 	rx_ring->r_vec = r_vec;
+	u64_stats_init(&rx_ring->r_vec->rx_sync);
 
 	rx_ring->fl_qcidx = rx_ring->idx * nn->stride_rx;
 	rx_ring->qcp_fl = nn->rx_bar + NFP_QCP_QUEUE_OFF(rx_ring->fl_qcidx);
-- 
2.9.3
