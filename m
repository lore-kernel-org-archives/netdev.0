From: Gregory Haskins <ghaskins@novell.com>
Subject: [PATCH 1/2] net: fix vbus-enet Kconfig dependencies
Date: Fri, 16 Oct 2009 09:36:19 -0400
Message-ID: <20091016133618.13423.38066.stgit@dev.haskins.net>
References: <20091016133411.13423.36106.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759770AbZJPNhH@vger.kernel.org>
In-Reply-To: <20091016133411.13423.36106.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently select VBUS_PROXY when vbus-enet is enabled, which is
the wrong direction.  Not all platforms will define VBUS-PROXY, and
venet depends on its inclusion.  Therefore, lets fix vbus-enet to
properly depend on the presence of VBUS_PROXY to get this right.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 47dfa04..c9128ea 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3233,7 +3233,7 @@ config VIRTIO_NET
 config VBUS_ENET
 	tristate "VBUS Ethernet Driver"
 	default n
-	select VBUS_PROXY
+	depends on VBUS_PROXY
 	help
 	   A virtualized 802.x network device based on the VBUS
 	   "virtual-ethernet" interface.  It can be used with any
