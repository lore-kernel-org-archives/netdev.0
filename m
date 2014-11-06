From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH RFC net-next 1/5] bonding: Expand speed type for AD Port Key
Date: Thu, 6 Nov 2014 19:52:48 +0800
Message-ID: <1415274772-8029-2-git-send-email-Jianhua.Xie@freescale.com>
References: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	"Veaceslav Falico" <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:14681
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750846AbaKFMJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 07:09:24 -0500
In-Reply-To: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

Port Key was determined as 16 bits according to the link speed,
duplex and user key (which is yet not supported), in which key
speed was 5 bits for 1Mbps/10Mbps/100Mbps/1Gbps/10Gbps as below:
--------------------------------------------------------------
Port key :|	User key	| Speed		|	Duplex|
--------------------------------------------------------------
16			6		1		0
This patch is expanding speed type from 5 bits to 9 bits for other
speed 2.5Gbps/20Gbps/40Gbps/56Gbps and shrinking user key from 10
bits to 6 bits. New Port Key looks like below:
--------------------------------------------------------------
Port key :|	User key	| Speed		|	Duplex|
--------------------------------------------------------------
16			10		1		0

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 2110215f..15821f3 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -77,11 +77,11 @@
  * --------------------------------------------------------------
  * Port key :	| User key	| Speed		| Duplex	|
  * --------------------------------------------------------------
- * 16		  6		  1		  0
+ * 16		  	10		  1		  0
  */
 #define  AD_DUPLEX_KEY_BITS    0x1
-#define  AD_SPEED_KEY_BITS     0x3E
-#define  AD_USER_KEY_BITS      0xFFC0
+#define  AD_SPEED_KEY_BITS     0x3FE
+#define  AD_USER_KEY_BITS      0xFC00
 
 #define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
-- 
2.1.0.27.g96db324
