From: Asias He <asias@redhat.com>
Subject: [RFC 5/5] VSOCK: Add Makefile and Kconfig
Date: Thu, 27 Jun 2013 16:00:04 +0800
Message-ID: <1372320004-20502-6-git-send-email-asias@redhat.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Reilly Grant <grantr@vmware.com>, Pekka Enberg <penberg@kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, Dmitry Torokhov <dtor@vmware.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372320004-20502-1-git-send-email-asias@redhat.com>
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

Enable virtio-vsock and vhost-vsock.

Signed-off-by: Asias He <asias@redhat.com>
---
 drivers/vhost/Kconfig       |  4 ++++
 drivers/vhost/Kconfig.vsock |  7 +++++++
 drivers/vhost/Makefile      |  5 +++++
 net/vmw_vsock/Kconfig       | 18 ++++++++++++++++++
 net/vmw_vsock/Makefile      |  4 ++++
 5 files changed, 38 insertions(+)
 create mode 100644 drivers/vhost/Kconfig.vsock

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 017a1e8..169fb19 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -32,3 +32,7 @@ config VHOST
 	---help---
 	  This option is selected by any driver which needs to access
 	  the core of vhost.
+
+if STAGING
+source "drivers/vhost/Kconfig.vsock"
+endif
diff --git a/drivers/vhost/Kconfig.vsock b/drivers/vhost/Kconfig.vsock
new file mode 100644
index 0000000..3491865
--- /dev/null
+++ b/drivers/vhost/Kconfig.vsock
@@ -0,0 +1,7 @@
+config VHOST_VSOCK
+	tristate "vhost virtio-vsock driver"
+	depends on VSOCKETS && EVENTFD
+	select VIRTIO_VSOCKETS_COMMON
+	default n
+	---help---
+	Say M here to enable the vhost-vsock for virtio-vsock guests
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index e0441c3..ddf87cb 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -4,5 +4,10 @@ vhost_net-y := net.o
 obj-$(CONFIG_VHOST_SCSI) += vhost_scsi.o
 vhost_scsi-y := scsi.o
 
+obj-$(CONFIG_VHOST_VSOCK) += vhost_vsock.o
+vhost_vsock-y := vsock.o
+#CFLAGS_vsock.o := -DDEBUG
+
 obj-$(CONFIG_VHOST_RING) += vringh.o
+
 obj-$(CONFIG_VHOST)	+= vhost.o
diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index b5fa7e4..c2b6d6f 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -26,3 +26,21 @@ config VMWARE_VMCI_VSOCKETS
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called vmw_vsock_vmci_transport. If unsure, say N.
+
+config VIRTIO_VSOCKETS
+	tristate "virtio transport for Virtual Sockets"
+	depends on VSOCKETS && VIRTIO
+	select VIRTIO_VSOCKETS_COMMON
+	help
+	  This module implements a virtio transport for Virtual Sockets.
+
+	  Enable this transport if your Virtual Machine runs on Qemu/KVM.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called virtio_vsock_transport. If unsure, say N.
+
+config VIRTIO_VSOCKETS_COMMON
+       tristate
+       ---help---
+         This option is selected by any driver which needs to access
+         the virtio_vsock.
diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
index 2ce52d7..bc37e59 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -1,5 +1,9 @@
 obj-$(CONFIG_VSOCKETS) += vsock.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS) += virtio_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += virtio_transport_common.o
+#CFLAGS_virtio_transport.o := -DDEBUG
+#CFLAGS_virtio_transport_common.o := -DDEBUG
 
 vsock-y += af_vsock.o vsock_addr.o
 
-- 
1.8.1.4
