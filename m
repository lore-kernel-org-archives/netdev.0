From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 v3] Add support for netvsc build without CONFIG_SYSFS flag
Date: Thu,  8 May 2014 15:14:10 -0700
Message-ID: <1399587250-27846-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This change ensures the driver can be built successfully without the
CONFIG_SYSFS flag.
MS-TFS: 182270

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 939e3af..083d084 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -640,8 +640,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 				       packet->vlan_tci);
 
 	skb_record_rx_queue(skb, packet->channel->
-			    offermsg.offer.sub_channel_index %
-			    net->real_num_rx_queues);
+			    offermsg.offer.sub_channel_index);
 
 	net->stats.rx_packets++;
 	net->stats.rx_bytes += packet->total_data_buflen;
@@ -824,8 +823,6 @@ static int netvsc_probe(struct hv_device *dev,
 	nvdev = hv_get_drvdata(dev);
 	netif_set_real_num_tx_queues(net, nvdev->num_chn);
 	netif_set_real_num_rx_queues(net, nvdev->num_chn);
-	dev_info(&dev->device, "real num tx,rx queues:%u, %u\n",
-		 net->real_num_tx_queues, net->real_num_rx_queues);
 
 	ret = register_netdev(net);
 	if (ret != 0) {
-- 
1.7.4.1
