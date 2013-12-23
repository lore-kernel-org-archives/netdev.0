From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 05/21] atm: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:10:02 +0800
Message-ID: <52B7C5AA.9070602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	<linux-atm-general@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/atm/nicstar.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 5aca5f4..d636f7f 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -781,8 +781,7 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 	if (mac[i] == NULL || !mac_pton(mac[i], card->atmdev->esi)) {
 		nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET,
 				   card->atmdev->esi, 6);
-		if (memcmp(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00", 6) ==
-		    0) {
+		if (ether_addr_equal_unaligned(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00")) {
 			nicstar_read_eprom(card->membase,
 					   NICSTAR_EPROM_MAC_ADDR_OFFSET_ALT,
 					   card->atmdev->esi, 6);
-- 
1.8.0
