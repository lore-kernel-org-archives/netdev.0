From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] drivers/net/tg3.c: Raise Jumbo Frame MTU to 9216?
Date: Wed, 15 Sep 2010 10:41:56 -0700
Message-ID: <1284572516.10223.12.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Benjamin Li <benli@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TG3 apparently supports 9K frame sizes.

http://www.broadcom.com/collateral/pb/5704C-PB05-R.pdf

Is exactly 9000 a hardware limit?

Should the jumbo frame MTU be raised to 9216 or 9216
less the size of MAC, VLAN, IP and TCP headers?

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9f6ffff..3727070 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -95,7 +95,7 @@
 /* hardware minimum and maximum for a single frame's data payload */
 #define TG3_MIN_MTU			60
 #define TG3_MAX_MTU(tp)	\
-	((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ? 9000 : 1500)
+	((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ? 9216 : 1500)
 
 /* These numbers seem to be hard coded in the NIC firmware somehow.
  * You can't change the ring sizes, but you can change where you place
