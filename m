From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/2] net: dsa: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 14:17:31 -0400
Message-ID: <20171023181731.7977-3-vivien.didelot@savoirfairelinux.com>
References: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The unapply functions are called on the error path.

As for dsa_port_mask, enabled_port_mask and cpu_port_mask won't be used
after so there's no need to unmask the corresponding port bit from them.

This makes dsa_cpu_port_unapply() and dsa_dsa_port_unapply() identical,
which can be factorized later.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 9e8b8aab049d..62485a57dbfc 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -260,8 +260,6 @@ static void dsa_cpu_port_unapply(struct dsa_port *port)
 {
 	devlink_port_unregister(&port->devlink_port);
 	dsa_cpu_dsa_destroy(port);
-	port->ds->cpu_port_mask &= ~BIT(port->index);
-
 }
 
 static int dsa_user_port_apply(struct dsa_port *port)
@@ -300,7 +298,6 @@ static void dsa_user_port_unapply(struct dsa_port *port)
 	if (port->slave) {
 		dsa_slave_destroy(port->slave);
 		port->slave = NULL;
-		port->ds->enabled_port_mask &= ~(1 << port->index);
 	}
 }
 
@@ -512,7 +509,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
-		ds->cpu_port_mask &= ~BIT(index);
 		return PTR_ERR(tag_ops);
 	}
 
-- 
2.14.2
