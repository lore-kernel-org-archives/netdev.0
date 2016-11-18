From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] vhost: forbid IOTLB invalidation when not enabled
Date: Fri, 18 Nov 2016 15:58:40 +0800
Message-ID: <1479455920-3285-2-git-send-email-jasowang@redhat.com>
References: <1479455920-3285-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com, jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1479455920-3285-1-git-send-email-jasowang@redhat.com>
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

When IOTLB is not enabled, we should forbid IOTLB invalidation to
avoid a NULL pointer dereference.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89..7d338d5 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -959,6 +959,10 @@ int vhost_process_iotlb_msg(struct vhost_dev *dev,
 		vhost_iotlb_notify_vq(dev, msg);
 		break;
 	case VHOST_IOTLB_INVALIDATE:
+		if (!dev->iotlb) {
+			ret = -EFAULT;
+			break;
+		}
 		vhost_del_umem_range(dev->iotlb, msg->iova,
 				     msg->iova + msg->size - 1);
 		break;
-- 
2.7.4
