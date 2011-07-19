From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: fix zcopy reference counting
Date: Tue, 19 Jul 2011 13:33:16 +0300
Message-ID: <20110719103316.GA5376@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix get/put refcount imbalance with zero copy,
which caused qemu to hang forever on guest driver unload.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, I've put this on my tree so no need for you to bother.

 drivers/vhost/vhost.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 46822c0..c16d225 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1578,7 +1578,6 @@ struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *vq,
 	if (!ubufs)
 		return ERR_PTR(-ENOMEM);
 	kref_init(&ubufs->kref);
-	kref_get(&ubufs->kref);
 	init_waitqueue_head(&ubufs->wait);
 	ubufs->vq = vq;
 	return ubufs;
-- 
1.7.5.53.gc233e
