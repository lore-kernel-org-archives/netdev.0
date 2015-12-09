From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 4/4] VSOCK: Add Makefile and Kconfig
Date: Wed,  9 Dec 2015 20:03:53 +0800
Message-ID: <1449662633-26623-5-git-send-email-stefanha@redhat.com>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	matt.ma@linaro.org, virtualization@lists.linux-foundation.org,
	Asias He <asias@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>

Enable virtio-vsock and vhost-vsock.

Signed-off-by: Asias He <asias@redhat.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
v3:
 * Don't put vhost vsock driver into staging
 * Add missing Kconfig dependencies (Arnd Bergmann <arnd@arndb.de>)
---
 drivers/vhost/Kconfig  | 10 ++++++++++
 drivers/vhost/Makefile |  4 ++++
 net/vmw_vsock/Kconfig  | 18 ++++++++++++++++++
 net/vmw_vsock/Makefile |  2 ++
 4 files changed, 34 insertions(+)

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 533eaf0..a1bb4c2 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -21,6 +21,16 @@ config VHOST_SCSI
 	Say M here to enable the vhost_scsi TCM fabric module
 	for use with virtio-scsi guests
 
+config VHOST_VSOCK
+	tristate "vhost virtio-vsock driver"
+	depends on VSOCKETS && EVENTFD
+	select VIRTIO_VSOCKETS_COMMON
+	select VHOST
+	select VHOST_RING
+	default n
+	---help---
+	Say M here to enable the vhost-vsock for virtio-vsock guests
+
 config VHOST_RING
 	tristate
 	---help---
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
2.5.0

