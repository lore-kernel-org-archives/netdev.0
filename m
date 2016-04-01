From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mvpp2: use cache_line_size() to get cacheline size
Date: Fri, 1 Apr 2016 17:11:05 +0800
Message-ID: <1459501865-7033-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Jisheng Zhang <jszhang@marvell.com>
To: <davem@davemloft.net>, <mw@semihalf.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

L1_CACHE_BYTES may not be the real cacheline size, use cache_line_size
to determine the cacheline size in runtime.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 05f358b..23f3c08 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -376,7 +376,7 @@
 
 #define MVPP2_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVPP2_MH_SIZE + MVPP2_VLAN_TAG_LEN + \
-	      ETH_HLEN + ETH_FCS_LEN, L1_CACHE_BYTES)
+	      ETH_HLEN + ETH_FCS_LEN, cache_line_size())
 
 #define MVPP2_RX_BUF_SIZE(pkt_size)	((pkt_size) + NET_SKB_PAD)
 #define MVPP2_RX_TOTAL_SIZE(buf_size)	((buf_size) + MVPP2_SKB_SHINFO_SIZE)
-- 
2.8.0.rc3
