From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 02/16] virtio/9p: verify device has config space
Date: Wed, 14 Jan 2015 19:27:28 +0200
Message-ID: <1421256142-11512-3-git-send-email-mst@redhat.com>
References: <1421256142-11512-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>, netdev@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, Ron Minnich <rminnich@sandia.gov>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1421256142-11512-1-git-send-email-mst@redhat.com>
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
