From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) sk98lin -- build on smp fix
Date: Fri, 26 Sep 2003 11:17:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926111747.27199054.shemminger@osdl.org>
References: <20030904160658.5ae22c0d.shemminger@osdl.org>
	<1220606764.18887.129.camel@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Ralph Roesler <rroesler@syskonnect.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <1220606764.18887.129.camel@mlindner-lin>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is no exported variable called smp_num_cpus! so this driver
won't build on SMP.  Since the local variable is never used anyway
just get rid of it.

This applies against 2.6.0-test5-bk13 which has the last vendor
driver update.

diff -Nru a/drivers/net/sk98lin/skdim.c b/drivers/net/sk98lin/skdim.c
--- a/drivers/net/sk98lin/skdim.c	Fri Sep 26 11:01:04 2003
+++ b/drivers/net/sk98lin/skdim.c	Fri Sep 26 11:01:04 2003
@@ -318,11 +318,6 @@
 	unsigned int  TotalTime   = 0;
 	unsigned int  UsedTime    = 0;
 	unsigned int  SystemLoad  = 0;
-#ifdef CONFIG_SMP
-	unsigned int  SKNumCpus   = smp_num_cpus;
-#else
-	unsigned int  SKNumCpus   = 1;
-#endif
 
 	/* unsigned int  NbrCpu      = 0; */
 
