From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 4/4] xen-netback: skip IPv4 and IPv6 interfaces
Date: Fri, 14 Feb 2014 18:59:40 -0800
Message-ID: <1392433180-16052-5-git-send-email-mcgrof@do-not-panic.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The xen-netback driver is used only to provide a backend
interface for the frontend. The link is the only thing we
use, and that is used internally for letting us know when the
xen-netfront is ready, when it switches to XenbusStateConnected.

Note that only when the both the xen-netfront and xen-netback
are both in state XenbusStateConnected will xen-netback allow
userspace on the host (backend) to bring up the interface. Enabling
and disabling the interface will simply enable or disable NAPI
respectively, and that's used for IRQ communication set up with
the xen event channels.

Cc: Paul Durrant <Paul.Durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: xen-devel@lists.xenproject.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/xen-netback/interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index d380e3f..07e6fd2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -351,7 +351,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	eth_hw_addr_random(dev);
 	memcpy(dev->dev_addr, xen_oui, 3);
-	dev->priv_flags |= IFF_BRIDGE_NON_ROOT;
+	dev->priv_flags |= IFF_BRIDGE_NON_ROOT | IFF_SKIP_IP;
 	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
 
 	netif_carrier_off(dev);
-- 
1.8.5.2
