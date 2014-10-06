From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 14/15] 9p/trans_virtio: enable VQs early
Date: Mon, 6 Oct 2014 18:11:29 +0300
Message-ID: <1412608214-31944-15-git-send-email-mst@redhat.com>
References: <1412608214-31944-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	v9fs-developer@lists.sourceforge.net, Ron Minnich <rminnich@sandia.gov>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1412608214-31944-1-git-send-email-mst@redhat.com>
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

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after probe returns, but virtio 9p device
adds self to channel list within probe, at which point VQ can be
used in violation of the spec.

To fix, call virtio_enable_vqs_early before using VQs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/9p/trans_virtio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 6940d8f..766ba48 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -575,6 +575,8 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 	/* Ceiling limit to avoid denial of service attacks */
 	chan->p9_max_pages = nr_free_buffer_pages()/4;
 
+	virtio_enable_vqs_early(vdev);
+
 	mutex_lock(&virtio_9p_lock);
 	list_add_tail(&chan->chan_list, &virtio_chan_list);
 	mutex_unlock(&virtio_9p_lock);
-- 
MST
