From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 05/20] net: benet: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:17:24 +0800
Message-ID: <52BE6CF4.2010107@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f67586a..b5c238a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -287,7 +287,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	/* The MAC change did not happen, either due to lack of privilege
 	 * or PF didn't pre-provision.
 	 */
-	if (memcmp(addr->sa_data, mac, ETH_ALEN)) {
+	if (!ether_addr_equal(addr->sa_data, mac)) {
 		status = -EPERM;
 		goto err;
 	}
-- 
1.8.0
