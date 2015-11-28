From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 14/17] hv_netvsc: Eliminate completion_func from
 struct hv_netvsc_packet
Date: Sat, 28 Nov 2015 12:20:42 -0800
Message-ID: <1448742045-22732-14-git-send-email-kys@microsoft.com>
References: <1448742017-22693-1-git-send-email-kys@microsoft.com>
 <1448742045-22732-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448742045-22732-1-git-send-email-kys@microsoft.com>
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

Eliminate completion_func from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    1 -
 drivers/net/hyperv/netvsc_drv.c   |    3 ---
 drivers/net/hyperv/rndis_filter.c |    1 -
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 65e340e..ddf51a0 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -137,7 +137,6 @@ struct hv_netvsc_packet {
 	u8 rmsg_size; /* RNDIS header and PPI size */
 	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
 	u8 page_buf_cnt;
-	u8 completion_func;
 
 	u16 vlan_tci;
 	u16 q_idx;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index eb0c6fa..bc4be1d 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -483,9 +483,6 @@ check_size:
 
 	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
 
-	/* Set the completion routine */
-	packet->completion_func = 1;
-
 	isvlan = packet->vlan_tci & VLAN_TAG_PRESENT;
 
 	/* Add the rndis header */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0b98674..6ba5adf 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -236,7 +236,6 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 			pb[0].len;
 	}
 
-	packet->completion_func = 0;
 	packet->xmit_more = false;
 
 	ret = netvsc_send(dev->net_dev->dev, packet, NULL, &pb, NULL);
-- 
1.7.4.1
