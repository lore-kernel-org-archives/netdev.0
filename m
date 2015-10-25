From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/8] netdev/phy: add missing of_node_put
Date: Sun, 25 Oct 2015 14:57:02 +0100
Message-ID: <1445781427-7110-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Jason Cooper <jason@lakedaemon.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

for_each_available_child_of_node performs an of_node_get on each iteration, so
a break out of the loop requires an of_node_put.

A simplified version of the semantic patch that fixes this problem is as
follows (http://coccinelle.lip6.fr):

// <smpl>
@@
local idexpression r.n;
expression r,e;
@@

 for_each_available_child_of_node(r,n) {
   ...
(
   of_node_put(n);
|
   e = n
|
+  of_node_put(n);
?  break;
)
   ...
 }
... when != n
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/phy/mdio-mux.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 280c7c3..908e8d4 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -144,6 +144,7 @@ int mdio_mux_init(struct device *dev,
 			dev_err(dev,
 				"Error: Failed to allocate memory for child\n");
 			ret_val = -ENOMEM;
+			of_node_put(child_bus_node);
 			break;
 		}
 		cb->bus_number = v;

