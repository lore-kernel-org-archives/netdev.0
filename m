From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] vhost: vsock: select CONFIG_VHOST
Date: Tue, 08 Dec 2015 16:46:08 +0100
Message-ID: <36261336.7BBY96nNaM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Asias He <asias@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:65005 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965079AbbLHPqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 10:46:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building the new vsock code without vhost, we get a build error:

drivers/built-in.o: In function `vhost_vsock_flush':
:(.text+0x24d29c): undefined reference to `vhost_poll_flush'

This adds an explicit 'select' like we have for the other vhost
drivers.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/vhost/Kconfig.vsock | 2 ++
 1 file changed, 2 insertions(+)

The patch causing the problem is currently in net-next, so the fix should be
applied on top of that.

diff --git a/drivers/vhost/Kconfig.vsock b/drivers/vhost/Kconfig.vsock
index 3491865d3eb9..bfb9edc4b5d6 100644
--- a/drivers/vhost/Kconfig.vsock
+++ b/drivers/vhost/Kconfig.vsock
@@ -2,6 +2,8 @@ config VHOST_VSOCK
 	tristate "vhost virtio-vsock driver"
 	depends on VSOCKETS && EVENTFD
 	select VIRTIO_VSOCKETS_COMMON
+	select VHOST
+	select VHOST_RING
 	default n
 	---help---
 	Say M here to enable the vhost-vsock for virtio-vsock guests
-- 
2.1.0.rc2
