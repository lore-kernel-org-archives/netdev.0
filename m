From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/6) tokenring probing change
Date: Wed, 15 Oct 2003 13:53:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015135303.705974a4.shemminger@osdl.org>
References: <200310152047.h9FKltw11805@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <200310152047.h9FKltw11805@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ugh, two patches got crossed. This is the correct first one.
-------------------------------------------------------------------
Convert ISA token ring drivers to the new probe2 infrastructure
that allows driver to allocate network device in the same way
for both modular and non-modular cases.

This applies against net-2.5-exp

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Oct 10 11:27:32 2003
+++ b/drivers/net/Space.c	Fri Oct 10 11:27:32 2003
@@ -414,6 +414,10 @@
 extern int proteon_probe(struct net_device *);
 extern int smctr_probe(struct net_device *);
 
+static struct devprobe2 tr_probes2[] __initdata = {
+	{NULL, 0},
+};
+
 static __init int trif_probe(int unit)
 {
 	struct net_device *dev;
@@ -446,6 +450,15 @@
 	return err;
 
 }
+
+static void __init trif_probe2(int unit)
+{
+	unsigned long base_addr = netdev_boot_base("tr", unit);
+
+	if (base_addr == 1)
+		return;
+	probe_list2(unit, tr_probes2, base_addr == 0);
+}
 #endif
 
 	
@@ -471,7 +484,8 @@
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		trif_probe(num);
+		if (!trif_probe(num))
+			trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
 		if (!ethif_probe(num))
