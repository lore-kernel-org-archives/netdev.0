From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] random: remove TCP MD4 code if !CONFIG_INET
Date: Wed, 17 Nov 2004 15:21:16 -0800
Message-ID: <20041117152116.6934bfa9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The code in the random driver for tcp sequence number randomization
is only needed if INET is configured.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/char/random.c b/drivers/char/random.c
--- a/drivers/char/random.c	2004-11-17 15:19:35 -08:00
+++ b/drivers/char/random.c	2004-11-17 15:19:35 -08:00
@@ -2046,6 +2046,7 @@
  *
  ********************************************************************/
 
+#ifdef CONFIG_INET
 /*
  * TCP initial sequence number picking.  This uses the random number
  * generator to pick an initial secret value.  This value is hashed
@@ -2445,3 +2446,4 @@
 	return (cookie - tmp[17]) & COOKIEMASK;	/* Leaving the data behind */
 }
 #endif
+#endif /* CONFIG_INET */
