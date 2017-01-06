From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 2/8] net: netcp: remove the redundant memmov()
Date: Fri, 6 Jan 2017 15:37:40 -0500
Message-ID: <1483735066-14632-3-git-send-email-m-karicheri2@ti.com>
References: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The psdata is populated with command data by netcp modules
to the tail of the buffer and set_words() copy the same
to the front of the psdata. So remove the redundant memmov
function call.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index a136c56..286fd8d 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1226,9 +1226,9 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 		/* psdata points to both native-endian and device-endian data */
 		__le32 *psdata = (void __force *)p_info.psdata;
 
-		memmove(p_info.psdata, p_info.psdata + p_info.psdata_len,
-			p_info.psdata_len);
-		set_words(p_info.psdata, p_info.psdata_len, psdata);
+		set_words((u32 *)psdata +
+			  (KNAV_DMA_NUM_PS_WORDS - p_info.psdata_len),
+			  p_info.psdata_len, psdata);
 		tmp |= (p_info.psdata_len & KNAV_DMA_DESC_PSLEN_MASK) <<
 			KNAV_DMA_DESC_PSLEN_SHIFT;
 	}
-- 
1.9.1
