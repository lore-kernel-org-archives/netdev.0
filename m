From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH 2/6] e100: Cocci spatch "pool_zalloc-simple"
Date: Thu, 21 Sep 2017 08:15:26 +0200
Message-ID: <1505974468535-1590578387-2-diffsplit-thomas@m3y3r.de>
References: <1505974468535-2047238743-0-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505974468535-2047238743-0-diffsplit-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use *_pool_zalloc rather than *_pool_alloc followed by memset with 0.
Found by coccinelle spatch "api/alloc/pool_zalloc-simple.cocci"

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1910,11 +1910,10 @@ static int e100_alloc_cbs(struct nic *ni
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = NULL;
 	nic->cbs_avail = 0;
 
-	nic->cbs = pci_pool_alloc(nic->cbs_pool, GFP_KERNEL,
-				  &nic->cbs_dma_addr);
+	nic->cbs = pci_pool_zalloc(nic->cbs_pool, GFP_KERNEL,
+				   &nic->cbs_dma_addr);
 	if (!nic->cbs)
 		return -ENOMEM;
-	memset(nic->cbs, 0, count * sizeof(struct cb));
 
 	for (cb = nic->cbs, i = 0; i < count; cb++, i++) {
 		cb->next = (i + 1 < count) ? cb + 1 : nic->cbs;
