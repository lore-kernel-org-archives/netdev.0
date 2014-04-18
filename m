From: Amos Kong <akong@redhat.com>
Subject: [PATCH] virtio_net: zero is an invald queue_pairs number
Date: Fri, 18 Apr 2014 13:45:41 +0800
Message-ID: <1397799941-11371-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Execute "ethtool -L eth0 combined 0" in guest, if multiqueue
is enabled, virtnet_send_command() will return -EINVAL error,
there is a validation in QEMU.

But if multiqueue is disabled, virtnet_set_queues() will just
return zero (success). We should return error for this situation.

Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7b68746..8a852b5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1285,7 +1285,7 @@ static int virtnet_set_channels(struct net_device *dev,
 	if (channels->rx_count || channels->tx_count || channels->other_count)
 		return -EINVAL;
 
-	if (queue_pairs > vi->max_queue_pairs)
+	if (queue_pairs > vi->max_queue_pairs || queue_pairs == 0)
 		return -EINVAL;
 
 	get_online_cpus();
-- 
1.9.0
