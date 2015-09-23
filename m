From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 5/7] net: netcp: check for interface handle in netcp_module_probe()
Date: Wed, 23 Sep 2015 13:37:09 -0400
Message-ID: <1443029831-22035-6-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently netcp_module_probe() doesn't check the return value of
of_parse_phandle() that points to the interface data for the
module and then pass the node ptr to the module which is incorrect.
Check for return value and free the intf_modpriv if there is error.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 97e2629..d39dce3 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -299,6 +299,11 @@ static int netcp_module_probe(struct netcp_device *netcp_device,
 		interface = of_parse_phandle(netcp_intf->node_interface,
 					     module->name, 0);
 
+		if (!interface) {
+			devm_kfree(dev, intf_modpriv);
+			continue;
+		}
+
 		intf_modpriv->netcp_priv = netcp_intf;
 		intf_modpriv->netcp_module = module;
 		list_add_tail(&intf_modpriv->intf_list,
-- 
1.9.1
