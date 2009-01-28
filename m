From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/3] wimax: replace uses of __constant_{endian}
Date: Wed, 28 Jan 2009 00:00:20 -0800
Message-ID: <1233129620.6717.44.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:24547 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbZA1IAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 03:00:24 -0500
Received: by wf-out-1314.google.com with SMTP id 27so7956090wfd.4
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 00:00:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Base versions handle constant folding now.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Separated from the net omnibus as this is mostly dealing with le-hardware
registers rather than protocol headers as the rest of the net/ stuff is.

 drivers/net/wimax/i2400m/fw.c     |   12 ++++++------
 drivers/net/wimax/i2400m/i2400m.h |   16 ++++++++--------
 drivers/net/wimax/i2400m/netdev.c |    2 +-
 drivers/net/wimax/i2400m/sdio.c   |   16 ++++++++--------
 drivers/net/wimax/i2400m/usb.c    |   16 ++++++++--------
 5 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 1d8271f..ecd0cfa 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -140,10 +140,10 @@
 

 static const __le32 i2400m_ACK_BARKER[4] = {
-	__constant_cpu_to_le32(I2400M_ACK_BARKER),
-	__constant_cpu_to_le32(I2400M_ACK_BARKER),
-	__constant_cpu_to_le32(I2400M_ACK_BARKER),
-	__constant_cpu_to_le32(I2400M_ACK_BARKER)
+	cpu_to_le32(I2400M_ACK_BARKER),
+	cpu_to_le32(I2400M_ACK_BARKER),
+	cpu_to_le32(I2400M_ACK_BARKER),
+	cpu_to_le32(I2400M_ACK_BARKER)
 };
 

@@ -771,8 +771,8 @@ static
 int i2400m_dnload_init_nonsigned(struct i2400m *i2400m)
 {
 #define POKE(a, d) {					\
-	.address = __constant_cpu_to_le32(a),		\
-	.data = __constant_cpu_to_le32(d)		\
+	.address = cpu_to_le32(a),		\
+	.data = cpu_to_le32(d)		\
 }
 	static const struct {
 		__le32 address;
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 067c871..236f19e 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -664,17 +664,17 @@ extern struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *, size_t *);
 extern void i2400m_tx_msg_sent(struct i2400m *);
 
 static const __le32 i2400m_NBOOT_BARKER[4] = {
-	__constant_cpu_to_le32(I2400M_NBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_NBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_NBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_NBOOT_BARKER)
+	cpu_to_le32(I2400M_NBOOT_BARKER),
+	cpu_to_le32(I2400M_NBOOT_BARKER),
+	cpu_to_le32(I2400M_NBOOT_BARKER),
+	cpu_to_le32(I2400M_NBOOT_BARKER)
 };
 
 static const __le32 i2400m_SBOOT_BARKER[4] = {
-	__constant_cpu_to_le32(I2400M_SBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_SBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_SBOOT_BARKER),
-	__constant_cpu_to_le32(I2400M_SBOOT_BARKER)
+	cpu_to_le32(I2400M_SBOOT_BARKER),
+	cpu_to_le32(I2400M_SBOOT_BARKER),
+	cpu_to_le32(I2400M_SBOOT_BARKER),
+	cpu_to_le32(I2400M_SBOOT_BARKER)
 };
 

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 57159e4..be8be4d 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -419,7 +419,7 @@ void i2400m_rx_fake_eth_header(struct net_device *net_dev,
 
 	memcpy(eth_hdr->h_dest, net_dev->dev_addr, sizeof(eth_hdr->h_dest));
 	memset(eth_hdr->h_source, 0, sizeof(eth_hdr->h_dest));
-	eth_hdr->h_proto = __constant_cpu_to_be16(ETH_P_IP);
+	eth_hdr->h_proto = cpu_to_be16(ETH_P_IP);
 }
 

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 1bfa283..123a5f8 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -255,16 +255,16 @@ int i2400ms_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 		container_of(i2400m, struct i2400ms, i2400m);
 	struct device *dev = i2400m_dev(i2400m);
 	static const __le32 i2400m_WARM_BOOT_BARKER[4] = {
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
 	};
 	static const __le32 i2400m_COLD_BOOT_BARKER[4] = {
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
 	};
 
 	if (rt == I2400M_RT_WARM)
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index c6d9346..7c28610 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -211,16 +211,16 @@ int i2400mu_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 		container_of(i2400m, struct i2400mu, i2400m);
 	struct device *dev = i2400m_dev(i2400m);
 	static const __le32 i2400m_WARM_BOOT_BARKER[4] = {
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
+		cpu_to_le32(I2400M_WARM_RESET_BARKER),
 	};
 	static const __le32 i2400m_COLD_BOOT_BARKER[4] = {
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
-		__constant_cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
+		cpu_to_le32(I2400M_COLD_RESET_BARKER),
 	};
 
 	d_fnstart(3, dev, "(i2400m %p rt %u)\n", i2400m, rt);
-- 
1.6.1.401.gf39d5


