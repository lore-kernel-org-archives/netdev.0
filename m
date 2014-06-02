From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: [PATCH 3.4] xen-netback: allow changing the MAC address of the interface
Date: Mon,  2 Jun 2014 21:46:20 +0200
Message-ID: <1401738380-11102-1-git-send-email-daniel.kiper@oracle.com>
Cc: Matt Wilson <msw@amazon.com>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Kiper <daniel.kiper@oracle.com>
To: gregkh@linuxfoundation.org, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Wilson <msw@amazon.com>

Sometimes it is useful to be able to change the MAC address of the
interface for netback devices. For example, when using ebtables it may
be useful to be able to distinguish traffic from different interfaces
without depending on the interface name.

Reported-by: Nikita Borzykh <sample.n@gmail.com>
Reported-by: Paul Harvey <stockingpaul@hotmail.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xen.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Signed-off-by: Matt Wilson <msw@amazon.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 4a633a602c26497b8285a202830829d3be007c7b)

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
Tested-by: Daniel Kiper <daniel.kiper@oracle.com>
Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netback/interface.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index cfaaf68..13aa5c1 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -239,6 +239,8 @@ static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_stop	= xenvif_close,
 	.ndo_change_mtu	= xenvif_change_mtu,
 	.ndo_fix_features = xenvif_fix_features,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr   = eth_validate_addr,
 };
 
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
-- 
1.7.10.4
