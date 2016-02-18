From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: add software transmit timestamp support
Date: Wed, 17 Feb 2016 16:43:59 -0800
Message-ID: <1455756239-20721-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kys@microsoft.com, haiyangz@microsoft.com, devel@linuxdriverproject.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

Enable skb_tx_timestamp in hyperv netvsc.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c72e5b8..202e2b1 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -550,6 +550,8 @@ do_send:
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
 					       skb, packet, &pb);
 
+	/* timestamp packet in software */
+	skb_tx_timestamp(skb);
 	ret = netvsc_send(net_device_ctx->device_ctx, packet,
 			  rndis_msg, &pb, skb);
 
@@ -920,6 +922,7 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 	.get_channels   = netvsc_get_channels,
 	.set_channels   = netvsc_set_channels,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops device_ops = {
-- 
2.5.0
