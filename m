From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] (2/3) PPPoE fix oops on /proc/net/pppoe
Date: Fri, 20 Jun 2003 17:33:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620173324.47071b18.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reading /proc/net/pppoe will OOPs because it calls hash_item() when the object pointer (po)
is null.

diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Fri Jun 20 17:16:43 2003
+++ b/drivers/net/pppoe.c	Fri Jun 20 17:16:43 2003
@@ -1015,8 +1015,9 @@
 		goto out;
 	}
 	po = v;
-	po = po->next;
-	if (!po) {
+	if (po->next) 
+		po = po->next;
+	else {
 		int hash = hash_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
 
 		while (++hash < PPPOE_HASH_SIZE) {
