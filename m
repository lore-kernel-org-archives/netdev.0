From: Asias He <asias.hejun@gmail.com>
Subject: [RFC V2 6/7] VSOCK: Add Makefile and Kconfig
Date: Sat,  5 Jul 2014 11:23:15 +0800
Message-ID: <b3607045e49b567a73092f4d995fff636840c301.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53179 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760496AbaGEDYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 23:24:03 -0400
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asias He <asias@redhat.com>

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
index e0441c3..eccff51 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -4,5 +4,10 @@ vhost_net-y := net.o
 obj-$(CONFIG_VHOST_SCSI) += vhost_scsi.o
 vhost_scsi-y := scsi.o
 
+obj-$(CONFIG_VHOST_VSOCK) += vhost_vsock.o
+vhost_vsock-y := vsock.o
+CFLAGS_vsock.o := -DDEBUG
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
index 2ce52d7..a8fea3af 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -1,5 +1,9 @@
 obj-$(CONFIG_VSOCKETS) += vsock.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS) += virtio_transport.o
+obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += virtio_transport_common.o
+CFLAGS_virtio_transport.o := -DDEBUG
+CFLAGS_virtio_transport_common.o := -DDEBUG
 
 vsock-y += af_vsock.o vsock_addr.o
 
-- 
1.9.3
