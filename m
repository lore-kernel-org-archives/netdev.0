From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] ipconfig.c: De-clutter IP configuration report
Date: Mon, 10 Sep 2007 13:09:19 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709101249230.25038@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933387AbXIJMJn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Reformat the printk() calls removing leading new-line characters, making 
output being done line-by-line rather than partially and defining the log 
level used.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 The new code builds fine; no semantic changes.

 Please apply,

  Maciej

patch-mips-2.6.23-rc5-20070904-ipconfig-printk-2
diff -up --recursive --new-file linux-mips-2.6.23-rc5-20070904.macro/net/ipv4/ipconfig.c linux-mips-2.6.23-rc5-20070904/net/ipv4/ipconfig.c
--- linux-mips-2.6.23-rc5-20070904.macro/net/ipv4/ipconfig.c	2007-09-04 04:56:22.000000000 +0000
+++ linux-mips-2.6.23-rc5-20070904/net/ipv4/ipconfig.c	2007-09-10 11:53:19.000000000 +0000
@@ -1364,17 +1364,17 @@ static int __init ip_auto_config(void)
 	/*
 	 * Clue in the operator.
 	 */
-	printk("IP-Config: Complete:");
-	printk("\n      device=%s", ic_dev->name);
-	printk(", addr=%u.%u.%u.%u", NIPQUAD(ic_myaddr));
-	printk(", mask=%u.%u.%u.%u", NIPQUAD(ic_netmask));
-	printk(", gw=%u.%u.%u.%u", NIPQUAD(ic_gateway));
-	printk(",\n     host=%s, domain=%s, nis-domain=%s",
-	       utsname()->nodename, ic_domain, utsname()->domainname);
-	printk(",\n     bootserver=%u.%u.%u.%u", NIPQUAD(ic_servaddr));
-	printk(", rootserver=%u.%u.%u.%u", NIPQUAD(root_server_addr));
-	printk(", rootpath=%s", root_server_path);
-	printk("\n");
+	pr_info("IP-Config: Complete:\n");
+	pr_info("      device=%s, addr=%u.%u.%u.%u, "
+		"mask=%u.%u.%u.%u, gw=%u.%u.%u.%u,\n",
+		ic_dev->name, NIPQUAD(ic_myaddr),
+		NIPQUAD(ic_netmask), NIPQUAD(ic_gateway));
+	pr_info("      host=%s, domain=%s, nis-domain=%s,\n",
+		utsname()->nodename, ic_domain, utsname()->domainname);
+	pr_info("      bootserver=%u.%u.%u.%u, "
+		"rootserver=%u.%u.%u.%u, rootpath=%s\n",
+		NIPQUAD(ic_servaddr),
+		NIPQUAD(root_server_addr), root_server_path);
 #endif /* !SILENT */
 
 	return 0;
