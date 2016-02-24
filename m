From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 2/3] forcedeth: Use setup_timer()
Date: Wed, 24 Feb 2016 19:28:01 +0530
Message-ID: <20160224135801.GA14387@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

The Coccinelle semantic patch that fixes this problem is
as follows:
 
// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 75e88f4..9b0d7f4 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5629,12 +5629,8 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	u64_stats_init(&np->swstats_rx_syncp);
 	u64_stats_init(&np->swstats_tx_syncp);
 
-	init_timer(&np->oom_kick);
-	np->oom_kick.data = (unsigned long) dev;
-	np->oom_kick.function = nv_do_rx_refill;	/* timer handler */
-	init_timer(&np->nic_poll);
-	np->nic_poll.data = (unsigned long) dev;
-	np->nic_poll.function = nv_do_nic_poll;	/* timer handler */
+	setup_timer(&np->oom_kick, nv_do_rx_refill, (unsigned long)dev);
+	setup_timer(&np->nic_poll, nv_do_nic_poll, (unsigned long)dev);
 	init_timer_deferrable(&np->stats_poll);
 	np->stats_poll.data = (unsigned long) dev;
 	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
-- 
1.9.1
