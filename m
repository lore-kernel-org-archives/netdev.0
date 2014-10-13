From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 19/25] virtio_console: enable VQs early on restore
Date: Mon, 13 Oct 2014 10:51:19 +0300
Message-ID: <1413114332-626-20-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	virtualization@lists.linux-foundation.org, Arnd Bergmann <arnd@arndb.de>,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
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
This is set automatically after resume returns, virtio console violated this
rule by adding inbufs, which causes the VQ to be used directly within
restore.

To fix, call virtio_device_ready before using VQs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/char/virtio_console.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index 6ebe8f6..2ae843f 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -2184,6 +2184,8 @@ static int virtcons_restore(struct virtio_device *vdev)
 	if (ret)
 		return ret;
 
+	virtio_device_ready(portdev->vdev);
+
 	if (use_multiport(portdev))
 		fill_queue(portdev->c_ivq, &portdev->c_ivq_lock);
 
-- 
MST
