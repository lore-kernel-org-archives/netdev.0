From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 02/10] hv_netvsc: Rearrange the hv_negtvsc_packet to
 be space efficient
Date: Mon, 23 Nov 2015 15:28:58 -0800
Message-ID: <1448321346-21357-2-git-send-email-kys@microsoft.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448321346-21357-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Rearrange the elements of struct hv_negtvsc_packet for optimal layout -
eliminate unnecessary padding.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 972e562..7435673 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -128,32 +128,34 @@ struct ndis_tcp_ip_checksum_info;
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
 	u8 status;
-
 	u8 is_data_pkt;
 	u8 xmit_more; /* from skb */
 	u8 cp_partial; /* partial copy into send buffer */
 
-	u16 vlan_tci;
+	u8 rmsg_size; /* RNDIS header and PPI size */
+	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
+	u8 page_buf_cnt;
+	u8 pad0;
 
+	u16 vlan_tci;
 	u16 q_idx;
+	u32 send_buf_index;
+
+	u32 total_data_buflen;
+	u32 pad1;
+
 	struct vmbus_channel *channel;
 
 	u64 send_completion_tid;
 	void *send_completion_ctx;
 	void (*send_completion)(void *context);
 
-	u32 send_buf_index;
 
 	/* This points to the memory after page_buf */
 	struct rndis_message *rndis_msg;
 
-	u8 rmsg_size; /* RNDIS header and PPI size */
-	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
-
-	u32 total_data_buflen;
 	/* Points to the send/receive buffer where the ethernet frame is */
 	void *data;
-	u8 page_buf_cnt;
 	struct hv_page_buffer *page_buf;
 };
 
-- 
1.7.4.1
