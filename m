From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 03/18] vhost: fix 64 bit features
Date: Wed, 4 May 2011 23:50:52 +0300
Message-ID: <c69b269bd53b79aba852a124e96afdb8e64d1c82.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Update vhost_has_feature to make it work correctly for bit > 32.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..0f1bf33 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -117,7 +117,7 @@ struct vhost_dev {
 	struct vhost_memory __rcu *memory;
 	struct mm_struct *mm;
 	struct mutex mutex;
-	unsigned acked_features;
+	u64 acked_features;
 	struct vhost_virtqueue *vqs;
 	int nvqs;
 	struct file *log_file;
@@ -169,14 +169,14 @@ enum {
 			 (1 << VIRTIO_NET_F_MRG_RXBUF),
 };
 
-static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
+static inline bool vhost_has_feature(struct vhost_dev *dev, int bit)
 {
-	unsigned acked_features;
+	u64 acked_features;
 
 	/* TODO: check that we are running from vhost_worker or dev mutex is
 	 * held? */
 	acked_features = rcu_dereference_index_check(dev->acked_features, 1);
-	return acked_features & (1 << bit);
+	return acked_features & (1ull << bit);
 }
 
 #endif
-- 
1.7.5.53.gc233e
