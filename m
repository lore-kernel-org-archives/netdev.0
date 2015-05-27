From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 6/6] VSOCK: Add Makefile and Kconfig
Date: Wed, 27 May 2015 18:06:00 +0100
Message-ID: <1432746360-14940-7-git-send-email-stefanha@redhat.com>
References: <1432746360-14940-1-git-send-email-stefanha@redhat.com>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Asias He <asias@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1432746360-14940-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>

Enable virtio-vsock and vhost-vsock.

Signed-off-by: Asias He <asias@redhat.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/Kconfig       |  4 ++++
 drivers/vhost/Kconfig.vsock |  7 +++++++
 drivers/vhost/Makefile      |  4 ++++
 net/vmw_vsock/Kconfig       | 18 ++++++++++++++++++
 net/vmw_vsock/Makefile      |  2 ++
 5 files changed, 35 insertions(+)
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
index e0441c3..6b012b9 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -4,5 +4,9 @@ vhost_net-y := net.o
 obj-$(CONFIG_VHOST_SCSI) += vhost_scsi.o
 vhost_scsi-y := scsi.o
 
+obj-$(CONFIG_VHOST_VSOCK) += vhost_vsock.o
+vhost_vsock-y := vsock.o
+
 obj-$(CONFIG_VHOST_RING) += vringh.o
+
 obj-$(CONFIG_VHOST)	+= vhost.o
diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index 14810ab..74e0bc8 100644
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
index 2ce52d7..cf4c294 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -1,5 +1,7 @@
 obj-$(CONFIG_VSOCKETS) += vsock.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS) += virtio_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += virtio_transport_common.o
 
 vsock-y += af_vsock.o vsock_addr.o
 
-- 
2.4.1

