From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC V2 1/4] vhost: introduce queue_index for tracing
Date: Fri, 21 Mar 2014 17:41:50 +0800
Message-ID: <1395394913-19548-2-git-send-email-jasowang@redhat.com>
References: <1395394913-19548-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <virtio-dev-return-467-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <1395394913-19548-1-git-send-email-jasowang@redhat.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   | 1 +
 drivers/vhost/vhost.h | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index a0fa5de..85d666c 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -708,6 +708,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].done_idx = 0;
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
+		n->vqs[i].vq.queue_index = i;
 	}
 	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 35eeb2a..6e36416 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -96,6 +96,9 @@ struct vhost_virtqueue {
 	/* Last used index value we have signalled on */
 	bool signalled_used_valid;
 
+	/* Queue index used for tracing */
+	u16 queue_index;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
-- 
1.8.3.2
