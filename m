From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH 3/4] net: dsa: mv88e6xxx: Add support for ethernet switch
 88E6341/88E6141
Date: Mon, 19 Dec 2016 15:16:08 +0100
Message-ID: <20161219141610.30934-4-romain.perier@free-electrons.com>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Romain Perier <romain.perier@free-electrons.com>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, Nadav Haklai <nadavh@marvell.com>,
 Rob Herring <robh+dt@kernel.org>, Kumar Gala <galak@codeaurora.org>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161219141610.30934-1-romain.perier@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The Marvell 88E6341 device is single-chip, 6-port ethernet switch with
four integrated 10/100/1000Mbps ethernet transceivers and one high speed
SerDes interfaces. It is compatible with switches of family 88E6352.

This commit adds basic support for this switch by describing its
capabilities to the driver.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 14 ++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 +++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 76d944e..72ba24b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4086,6 +4086,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6321_ops,
 	},
 
+	[MV88E6341] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
+		.family = MV88E6XXX_FAMILY_6352,
+		.name = "Marvell 88E6341",
+		.num_databases = 4096,
+		.num_ports = 6,
+		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6352_ops,
+	},
+
 	[MV88E6350] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index af54bae..176d6c4 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -86,6 +86,7 @@
 #define PORT_SWITCH_ID_PROD_NUM_6097	0x099
 #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
 #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
+#define PORT_SWITCH_ID_PROD_NUM_6341	0x340
 #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
 #define PORT_SWITCH_ID_PROD_NUM_6161	0x161
 #define PORT_SWITCH_ID_PROD_NUM_6165	0x165
@@ -432,6 +433,7 @@ enum mv88e6xxx_model {
 	MV88E6290,
 	MV88E6320,
 	MV88E6321,
+	MV88E6341,
 	MV88E6350,
 	MV88E6351,
 	MV88E6352,
@@ -448,7 +450,7 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6185,	/* 6108 6121 6122 6131 6152 6155 6182 6185 */
 	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
 	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
-	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
+	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6341 6352 */
 	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */
 };
 
-- 
2.9.3
