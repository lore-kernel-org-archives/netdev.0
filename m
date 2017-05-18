From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 3/3] virtio-net: enable TSO/checksum offloads for Q-in-Q
	vlans
Date: Thu, 18 May 2017 09:31:05 -0400
Message-ID: <1495114265-23368-4-git-send-email-vyasevic@redhat.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Since virtio does not provide it's own ndo_features_check handler,
TSO, and now checksum offload, are disabled for stacked vlans.
Re-enable the support and let the host take care of it.  This
restores/improves Guest-to-Guest performance over Q-in-Q vlans.

CC: "Michael S. Tsirkin" <mst@redhat.com>
CC: Jason Wang <jasowang@redhat.com>
CC: virtualization@lists.linux-foundation.org
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8324a5e..341fb96 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2028,6 +2028,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
 	.ndo_xdp		= virtnet_xdp,
+	.ndo_features_check	= passthru_features_check,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
-- 
2.7.4
