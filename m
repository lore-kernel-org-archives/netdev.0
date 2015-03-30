From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 1/2] hv_netvsc: Cleanup the test for freeing skb when we use sendbuf mechanism
Date: Sun, 29 Mar 2015 21:08:41 -0700
Message-ID: <1427688522-27991-1-git-send-email-kys@microsoft.com>
References: <1427688478-27950-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427688478-27950-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for embedding the rndis state and other packet state into
the skb, cleanup the test for freeing the skb.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c     |    1 +
 drivers/net/hyperv/netvsc_drv.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index b81bd37..ecbd813 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -870,6 +870,7 @@ int netvsc_send(struct hv_device *device,
 		       (unsigned long)packet->send_completion_tid;
 
 		packet->page_buf_cnt = 0;
+		packet->send_completion_tid = 0;
 		packet->send_buf_index = section_index;
 		packet->total_data_buflen += msd_len;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0c99818..75beb89 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -234,11 +234,10 @@ static void netvsc_xmit_completion(void *context)
 	struct hv_netvsc_packet *packet = (struct hv_netvsc_packet *)context;
 	struct sk_buff *skb = (struct sk_buff *)
 		(unsigned long)packet->send_completion_tid;
-	u32 index = packet->send_buf_index;
 
 	kfree(packet);
 
-	if (skb && (index == NETVSC_INVALID_INDEX))
+	if (skb)
 		dev_kfree_skb_any(skb);
 }
 
-- 
1.7.4.1
