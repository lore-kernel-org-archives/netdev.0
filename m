From: David Decotigny <decot@google.com>
Subject: [PATCH 2/3] net-bonding: Fix minor/cosmetic type inconsistencies
Date: Wed, 13 Apr 2011 18:22:30 -0700
Message-ID: <1302744151-12452-2-git-send-email-decot@google.com>
References: <1302744151-12452-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302744151-12452-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __get_link_speed() function returns a u16 value which was stored
in a u32 local variable. This patch uses the return value directly,
thus fixing that minor type consistency.

The 'duplex' field in struct slave being encoded on 8 bits, to be more
consistent we use a u8 integer (instead of u16) whenever we copy it to
local variables.

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/bonding/bond_3ad.c  |    4 +---
 drivers/net/bonding/bond_main.c |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 494bf96..123dd60 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -716,11 +716,9 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
 static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 {
 	u32 bandwidth = 0;
-	u32 basic_speed;
 
 	if (aggregator->num_of_ports) {
-		basic_speed = __get_link_speed(aggregator->lag_ports);
-		switch (basic_speed) {
+		switch (__get_link_speed(aggregator->lag_ports)) {
 		case AD_LINK_SPEED_BITMASK_1MBPS:
 			bandwidth = aggregator->num_of_ports;
 			break;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8264ed7..145f9be 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3340,7 +3340,7 @@ static int bond_slave_netdev_event(unsigned long event,
 			slave = bond_get_slave_by_dev(bond, slave_dev);
 			if (slave) {
 				u16 old_speed = slave->speed;
-				u16 old_duplex = slave->duplex;
+				u8  old_duplex = slave->duplex;
 
 				bond_update_speed_duplex(slave);
 
-- 
1.7.3.1
