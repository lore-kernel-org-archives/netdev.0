From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next] virtio-net: fix build error when CONFIG_AVERAGE is
	not enabled
Date: Fri, 17 Jan 2014 01:27:08 -0800
Message-ID: <1389950828-24039-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Commit ab7db91705e9 ("virtio-net: auto-tune mergeable rx buffer size for
improved performance") introduced a virtio-net dependency on EWMA.
The inclusion of EWMA is controlled by CONFIG_AVERAGE. Fix build error
when CONFIG_AVERAGE is not enabled by adding select AVERAGE to
virtio-net's Kconfig entry.

Build failure reported using config make ARCH=s390 defconfig.

Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 drivers/net/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b45b240..f342278 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -236,6 +236,7 @@ config VETH
 config VIRTIO_NET
 	tristate "Virtio network driver"
 	depends on VIRTIO
+	select AVERAGE
 	---help---
 	  This is the virtual network driver for virtio.  It can be used with
 	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
-- 
1.8.5.2
