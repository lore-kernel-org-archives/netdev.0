From: Adrian Bunk <bunk@fs.tum.de>
Subject: [patch] remove com20020-isa.c unused variables
Date: Sat, 6 Dec 2003 09:57:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031206085736.GQ20739@fs.tum.de>
References: <20031205192828.GA15907@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20031205192828.GA15907@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

your experimental net driver queue patch introduced the following
compile warnings when compiling com20020-isa statically into the kernel:

<--  snip  -->

...
  CC      drivers/net/arcnet/com20020-isa.o
drivers/net/arcnet/com20020-isa.c: In function `com20020isa_setup':
drivers/net/arcnet/com20020-isa.c:189: warning: unused variable `lp'
drivers/net/arcnet/com20020-isa.c:188: warning: unused variable `dev'
...

<--  snip  -->


The fix is trivial (the net driver queue patch removes all uses of 
these variables):


--- linux-2.6.0-test11-full-no-smp/drivers/net/arcnet/com20020-isa.c.old	2003-12-06 09:51:10.000000000 +0100
+++ linux-2.6.0-test11-full-no-smp/drivers/net/arcnet/com20020-isa.c	2003-12-06 09:53:41.000000000 +0100
@@ -185,8 +185,6 @@
 #ifndef MODULE
 static int __init com20020isa_setup(char *s)
 {
-	struct net_device *dev;
-	struct arcnet_local *lp;
 	int ints[8];
 
 	s = get_options(s, 8, ints);



cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
