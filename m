From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.5 07/19] zd1211rw: slight optimization of addr compare
Date: Thu, 26 Dec 2013 19:40:43 +0800
Message-ID: <52BC15BB.8010500@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
instead of memcmp.

Cc: Daniel Drake <dsd@gentoo.org>
Cc: Ulrich Kunitz <kune@deine-taler.de>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/zd1211rw/zd_mac.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index eff79a3..e7af261 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -532,9 +532,8 @@ void zd_mac_tx_failed(struct urb *urb)
 		tx_hdr = (struct ieee80211_hdr *)skb->data;
 
 		/* we skip all frames not matching the reported destination */
-		if (unlikely(memcmp(tx_hdr->addr1, tx_status->mac, ETH_ALEN))) {
+		if (unlikely(!ether_addr_equal(tx_hdr->addr1, tx_status->mac)))
 			continue;
-		}
 
 		/* we skip all frames not matching the reported final rate */
 
@@ -997,7 +996,7 @@ static int filter_ack(struct ieee80211_hw *hw, struct ieee80211_hdr *rx_hdr,
 		    continue;
 
 		tx_hdr = (struct ieee80211_hdr *)skb->data;
-		if (likely(!memcmp(tx_hdr->addr2, rx_hdr->addr1, ETH_ALEN)))
+		if (likely(ether_addr_equal(tx_hdr->addr2, rx_hdr->addr1)))
 		{
 			found = 1;
 			break;
-- 
1.8.0
