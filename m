From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 07/10] hv_netvsc: Eliminate send_completion_ctx from
 struct hv_netvsc_packet
Date: Mon, 23 Nov 2015 15:29:03 -0800
Message-ID: <1448321346-21357-7-git-send-email-kys@microsoft.com>
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

Eliminate send_completion_ctx from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 -
 drivers/net/hyperv/netvsc.c     |    3 +--
 drivers/net/hyperv/netvsc_drv.c |    1 -
 3 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 9a3c972..9504ca9 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -146,7 +146,6 @@ struct hv_netvsc_packet {
 
 
 	u64 send_completion_tid;
-	void *send_completion_ctx;
 	struct hv_page_buffer *page_buf;
 };
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 34c16d1..0e0b723 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -653,8 +653,7 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 				netvsc_free_send_slot(net_device, send_index);
 			q_idx = nvsc_packet->q_idx;
 			channel = incoming_channel;
-			netvsc_xmit_completion(nvsc_packet->
-					       send_completion_ctx);
+			netvsc_xmit_completion(nvsc_packet);
 		}
 
 		num_outstanding_sends =
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6d71a1e..947b778 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -489,7 +489,6 @@ check_size:
 
 	/* Set the completion routine */
 	packet->completion_func = 1;
-	packet->send_completion_ctx = packet;
 	packet->send_completion_tid = (unsigned long)skb;
 
 	isvlan = packet->vlan_tci & VLAN_TAG_PRESENT;
-- 
1.7.4.1
