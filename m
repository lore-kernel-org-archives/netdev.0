From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/6] virtio/9p: verify device has config space
Date: Tue, 13 Jan 2015 16:43:10 +0200
Message-ID: <1421160167-18498-2-git-send-email-mst@redhat.com>
References: <1421160167-18498-1-git-send-email-mst@redhat.com>
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
In-Reply-To: <1421160167-18498-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices might not implement config space access
(e.g. remoteproc used not to - before 3.9).
virtio/9p needs config space access so make it
fail gracefully if not there.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/9p/trans_virtio.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index daa749c..d8e376a 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -524,6 +524,12 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 	int err;
 	struct virtio_chan *chan;
 
+	if (!vdev->config->get) {
+		dev_err(&vdev->dev, "%s failure: config access disabled\n",
+			__func__);
+		return -EINVAL;
+	}
+
 	chan = kmalloc(sizeof(struct virtio_chan), GFP_KERNEL);
 	if (!chan) {
 		pr_err("Failed to allocate virtio 9P channel\n");
-- 
MST
