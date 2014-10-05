From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 15/16] 9p/trans_virtio: enable VQs early
Date: Sun, 5 Oct 2014 19:07:33 +0300
Message-ID: <1412525038-15871-16-git-send-email-mst@redhat.com>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412525038-15871-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after probe returns, but virtio 9p device
adds self to channel list within probe, at which point VQ can be
used in violation of the spec.

To fix, call virtio_early_enable_vqs before using VQs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/9p/trans_virtio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 6940d8f..0e8bbb3 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -575,6 +575,8 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 	/* Ceiling limit to avoid denial of service attacks */
 	chan->p9_max_pages = nr_free_buffer_pages()/4;
 
+	virtio_early_enable_vqs(vdev);
+
 	mutex_lock(&virtio_9p_lock);
 	list_add_tail(&chan->chan_list, &virtio_chan_list);
 	mutex_unlock(&virtio_9p_lock);
-- 
MST
