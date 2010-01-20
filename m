From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix TUN=m VHOST_NET=y
Date: Wed, 20 Jan 2010 13:30:38 +0200
Message-ID: <20100120113037.GA9182@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab0ATLdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 06:33:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/built-in.o: In function `get_tun_socket':
    net.c:(.text+0x15436e): undefined reference to `tun_get_socket'

If tun is a module, vhost must be a module, too.
If tun is built-in or disabled, vhost can be built-in.

Note: TUN || !TUN might look a bit strange until you realize
that boolean logic rules do not apply for tristate variables.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

The above was already applied by Rusty, but got lost.
The patch is on top of net-next.

 drivers/vhost/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 9f409f4..9e93553 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -1,6 +1,6 @@
 config VHOST_NET
 	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
-	depends on NET && EVENTFD && EXPERIMENTAL
+	depends on NET && EVENTFD && (TUN || !TUN) && EXPERIMENTAL
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
 	  guest networking with virtio_net. Not to be confused with virtio_net
-- 
1.6.6.144.g5c3af
