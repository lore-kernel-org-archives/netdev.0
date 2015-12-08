From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 2/6] Revert "VSOCK: Add Makefile and Kconfig"
Date: Tue,  8 Dec 2015 19:57:32 +0800
Message-ID: <1449575856-28507-3-git-send-email-stefanha@redhat.com>
References: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
	Christoffer Dall <christoffer.dall@linaro.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932676AbbLHL5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 06:57:54 -0500
In-Reply-To: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 8a2a2029893b4c35d1aba2932111a1a164b9c948.

Keep virtio-vsock out-of-tree until the device specification is
finalized.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/Kconfig       |  4 ----
 drivers/vhost/Kconfig.vsock |  7 -------
 drivers/vhost/Makefile      |  4 ----
 net/vmw_vsock/Kconfig       | 18 ------------------
 net/vmw_vsock/Makefile      |  2 --
 5 files changed, 35 deletions(-)
 delete mode 100644 drivers/vhost/Kconfig.vsock

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 81449bf..533eaf0 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -47,7 +47,3 @@ config VHOST_CROSS_ENDIAN_LEGACY
 	  adds some overhead, it is disabled by default.
 
 	  If unsure, say "N".
-
-if STAGING
-source "drivers/vhost/Kconfig.vsock"
-endif
diff --git a/drivers/vhost/Kconfig.vsock b/drivers/vhost/Kconfig.vsock
deleted file mode 100644
index 3491865..0000000
--- a/drivers/vhost/Kconfig.vsock
+++ /dev/null
@@ -1,7 +0,0 @@
-config VHOST_VSOCK
-	tristate "vhost virtio-vsock driver"
-	depends on VSOCKETS && EVENTFD
-	select VIRTIO_VSOCKETS_COMMON
-	default n
-	---help---
-	Say M here to enable the vhost-vsock for virtio-vsock guests
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index 6b012b9..e0441c3 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -4,9 +4,5 @@ vhost_net-y := net.o
 obj-$(CONFIG_VHOST_SCSI) += vhost_scsi.o
 vhost_scsi-y := scsi.o
 
-obj-$(CONFIG_VHOST_VSOCK) += vhost_vsock.o
-vhost_vsock-y := vsock.o
-
 obj-$(CONFIG_VHOST_RING) += vringh.o
-
 obj-$(CONFIG_VHOST)	+= vhost.o
diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index 74e0bc8..14810ab 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -26,21 +26,3 @@ config VMWARE_VMCI_VSOCKETS
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called vmw_vsock_vmci_transport. If unsure, say N.
-
-config VIRTIO_VSOCKETS
-	tristate "virtio transport for Virtual Sockets"
-	depends on VSOCKETS && VIRTIO
-	select VIRTIO_VSOCKETS_COMMON
-	help
-	  This module implements a virtio transport for Virtual Sockets.
-
-	  Enable this transport if your Virtual Machine runs on Qemu/KVM.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called virtio_vsock_transport. If unsure, say N.
-
-config VIRTIO_VSOCKETS_COMMON
-       tristate
-       ---help---
-         This option is selected by any driver which needs to access
-         the virtio_vsock.
diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
index cf4c294..2ce52d7 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -1,7 +1,5 @@
 obj-$(CONFIG_VSOCKETS) += vsock.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
-obj-$(CONFIG_VIRTIO_VSOCKETS) += virtio_transport.o
-obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += virtio_transport_common.o
 
 vsock-y += af_vsock.o vsock_addr.o
 
-- 
2.5.0
