From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/3] bonding: Invert test
Date: Tue, 18 Feb 2014 09:42:47 -0800
Message-ID: <63cf685f6be365b2eff54db6bc1c6a3939983bd7.1392745014.git.joe@perches.com>
References: <cover.1392745013.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392745013.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the error case return early.
Make the normal return at the bottom of the function.
Reduces indent for readability.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7cb51f9..a0e12369 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2381,17 +2381,16 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 		}
 	}
 
-	if (aggregator) {
-		ad_info->aggregator_id = aggregator->aggregator_identifier;
-		ad_info->ports = aggregator->num_of_ports;
-		ad_info->actor_key = aggregator->actor_oper_aggregator_key;
-		ad_info->partner_key = aggregator->partner_oper_aggregator_key;
-		ether_addr_copy(ad_info->partner_system,
-				aggregator->partner_system.mac_addr_value);
-		return 0;
-	}
-
-	return -1;
+	if (!aggregator)
+		return -1;
+
+	ad_info->aggregator_id = aggregator->aggregator_identifier;
+	ad_info->ports = aggregator->num_of_ports;
+	ad_info->actor_key = aggregator->actor_oper_aggregator_key;
+	ad_info->partner_key = aggregator->partner_oper_aggregator_key;
+	ether_addr_copy(ad_info->partner_system,
+			aggregator->partner_system.mac_addr_value);
+	return 0;
 }
 
 /* Wrapper used to hold bond->lock so no slave manipulation can occur */
-- 
1.8.1.2.459.gbcd45b4.dirty
