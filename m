From: Ding Tianhong <dthxman@gmail.com>
Subject: [PATCH RESEND v2 03/20] net: pcnet: slight optimization of addr compare
Date: Tue, 24 Dec 2013 21:47:40 +0800
Message-ID: <52B9907C.6090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Don Fry <pcnet32@frontier.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Don Fry <pcnet32@frontier.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 38492e0..9339ccc 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1668,7 +1668,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	for (i = 0; i < ETH_ALEN; i++)
 		promaddr[i] = inb(ioaddr + i);
 
-	if (memcmp(promaddr, dev->dev_addr, ETH_ALEN) ||
+	if (!ether_addr_equal(promaddr, dev->dev_addr) ||
 	    !is_valid_ether_addr(dev->dev_addr)) {
 		if (is_valid_ether_addr(promaddr)) {
 			if (pcnet32_debug & NETIF_MSG_PROBE) {
-- 
1.8.0



--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
.
