From: Michał Mirosław <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 5/6 2.6.30-rc6] tipc: Use
	genl_register_family_with_ops()
Date: Thu, 21 May 2009 19:41:56 +0200 (CEST)
Message-ID: <20090521174156.6570613932@rere.qmqm.pl>
Content-Type: multipart/mixed; boundary="===============7944374672526115693=="
Cc: tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============7944374672526115693==

Use genl_register_family_with_ops() instead of a copy. This also changes
netlink related variable names to be kernel-wide unique for consistency
with other users.

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>

diff -urN linux-orig-mqbr/net/tipc/netlink.c linux-mqbr/net/tipc/netlink.c
--- linux-orig-mqbr/net/tipc/netlink.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-mqbr/net/tipc/netlink.c	2009-05-21 18:04:46.000000000 +0200
@@ -68,7 +68,7 @@
 	return 0;
 }
 
-static struct genl_family family = {
+static struct genl_family tipc_genl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_NAME,
 	.version	= TIPC_GENL_VERSION,
@@ -76,39 +76,33 @@
 	.maxattr	= 0,
 };
 
-static struct genl_ops ops = {
+static struct genl_ops tipc_genl_ops = {
 	.cmd		= TIPC_GENL_CMD,
 	.doit		= handle_cmd,
 };
 
-static int family_registered = 0;
+static int tipc_genl_family_registered;
 
 int tipc_netlink_start(void)
 {
+	int res;
 
+	res = genl_register_family_with_ops(&tipc_genl_family,
+		&tipc_genl_ops, 1);
+	if (res) {
+		err("Failed to register netlink interface\n");
+		return res;
+	}
 
-	if (genl_register_family(&family))
-		goto err;
-
-	family_registered = 1;
-
-	if (genl_register_ops(&family, &ops))
-		goto err_unregister;
-
+	tipc_genl_family_registered = 1;
 	return 0;
-
- err_unregister:
-	genl_unregister_family(&family);
-	family_registered = 0;
- err:
-	err("Failed to register netlink interface\n");
-	return -EFAULT;
 }
 
 void tipc_netlink_stop(void)
 {
-	if (family_registered) {
-		genl_unregister_family(&family);
-		family_registered = 0;
-	}
+	if (!tipc_genl_family_registered)
+		return;
+
+	genl_unregister_family(&tipc_genl_family);
+	tipc_genl_family_registered = 0;
 }


--===============7944374672526115693==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
--===============7944374672526115693==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
tipc-discussion mailing list
tipc-discussion@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/tipc-discussion

--===============7944374672526115693==--
