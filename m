From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost-net: initialize zcopy packet counters
Date: Mon, 3 Dec 2012 19:31:51 +0200
Message-ID: <20121203173151.GA30949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

These packet counters are used to drive the zercopy
selection heuristic so nothing too bad happens if they are off a bit -
and they are also reset once in a while.
But it's cleaner to clear them when backend is set so that
we start in a known state.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 67898fa..ff6c9199 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -823,6 +823,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		r = vhost_init_used(vq);
 		if (r)
 			goto err_vq;
+
+		n->tx_packets = 0;
+		n->tx_zcopy_err = 0;
 	}
 
 	mutex_unlock(&vq->mutex);
-- 
MST
