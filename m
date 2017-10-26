From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 9/9] net: dsa: remove port masks
Date: Thu, 26 Oct 2017 11:22:59 -0400
Message-ID: <20171026152259.3123-10-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that DSA core provides port types, there is no need to keep this
information at the switch level. This is a static information that is
part of a DSA core dsa_port structure. Remove them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  3 ---
 net/dsa/dsa2.c    | 11 -----------
 net/dsa/legacy.c  |  3 ---
 3 files changed, 17 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 07dfbd7f4fd5..50e276dc4c01 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -240,9 +240,6 @@ struct dsa_switch {
 	/*
 	 * Slave mii_bus and devices for the individual ports.
 	 */
-	u32			dsa_port_mask;
-	u32			cpu_port_mask;
-	u32			enabled_port_mask;
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index dd6f35b92937..ec58654a71cd 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -184,7 +184,6 @@ static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		if (err != 0)
 			return err;
 
-		ds->dsa_port_mask |= BIT(index);
 		port->type = DSA_PORT_TYPE_DSA;
 	}
 
@@ -500,11 +499,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		dst->cpu_dp->master = ethernet_dev;
 	}
 
-	/* Initialize cpu_port_mask now for drv->setup()
-	 * to have access to a correct value, just like what
-	 * net/dsa/dsa.c::dsa_switch_setup_one does.
-	 */
-	ds->cpu_port_mask |= BIT(index);
 	port->type = DSA_PORT_TYPE_CPU;
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
@@ -540,11 +534,6 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			if (err)
 				return err;
 		} else {
-			/* Initialize enabled_port_mask now for drv->setup()
-			 * to have access to a correct value, just like what
-			 * net/dsa/dsa.c::dsa_switch_setup_one does.
-			 */
-			ds->enabled_port_mask |= BIT(index);
 			port->type = DSA_PORT_TYPE_USER;
 		}
 
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 9fd5b3adab1e..93e1b116ef83 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -124,13 +124,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 			}
 			dst->cpu_dp = &ds->ports[i];
 			dst->cpu_dp->master = master;
-			ds->cpu_port_mask |= 1 << i;
 			dp->type = DSA_PORT_TYPE_CPU;
 		} else if (!strcmp(name, "dsa")) {
-			ds->dsa_port_mask |= 1 << i;
 			dp->type = DSA_PORT_TYPE_DSA;
 		} else {
-			ds->enabled_port_mask |= 1 << i;
 			dp->type = DSA_PORT_TYPE_USER;
 		}
 		valid_name_found = true;
-- 
2.14.3
