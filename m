From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] resolve probe difference
Date: Mon, 13 Oct 2003 11:48:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013114852.74b547d0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In the change to get rid of the list of ISA devices to programmatic probing
of old devices, a behaviour change was introduced which might cause problems.

Before, it was possible to specify a parameter on the boot line for a second
device and skip the first, as in:
	netdev=4,0x280,0,0,eth1
Well, now we stop after eth0 if we don't find it..
Somebody, might depend on the old behaviour, so this patch restores it..

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
+++ b/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
@@ -433,17 +433,15 @@
 	
 #ifdef CONFIG_SBNI
 	for (num = 0; num < 8; ++num)
-		if (sbni_probe(num))
-			break;
+		sbni_probe(num);
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (trif_probe(num))
-			break;
+		trif_probe(num);
 #endif
 	for (num = 0; num < 8; ++num)
-		if (ethif_probe(num))
-			break;
+		ethif_probe(num);
+
 #ifdef CONFIG_COPS
 	cops_probe(0);
 	cops_probe(1);
