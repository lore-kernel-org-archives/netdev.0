From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: copy_from_user -> __copy_from_user
Date: Sun, 6 Mar 2011 13:33:49 +0200
Message-ID: <20110306113349.GA24333@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

copy_from_user is pretty high on perf top profile,
replacing it with __copy_from_user helps.
It's also safe because we do access_ok checks during setup.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ade0568..01701b8 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1153,7 +1153,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			       i, vq->num, head);
 			return -EINVAL;
 		}
-		ret = copy_from_user(&desc, vq->desc + i, sizeof desc);
+		ret = __copy_from_user(&desc, vq->desc + i, sizeof desc);
 		if (unlikely(ret)) {
 			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
 			       i, vq->desc + i);
-- 
1.7.3.2.91.g446ac
