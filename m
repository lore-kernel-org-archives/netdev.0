From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen: causing lots of errors in console log
Date: Wed, 9 Mar 2005 12:10:01 +0100
Message-ID: <16942.55689.924299.906304@robur.slu.se>
References: <20050308140826.451435e5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050308140826.451435e5@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Hello!


Stephen Hemminger writes:
 > 1. Errors from IPV4
 > Freeing alive in_device ffff81007e96a400

Try:

--- net/core/pktgen.c.orig	2005-03-09 10:15:01.000000000 +0100
+++ net/core/pktgen.c	2005-03-09 10:24:19.000000000 +0100
@@ -151,7 +151,7 @@
 #include <asm/timex.h>
 
 
-#define VERSION  "pktgen v2.58: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.59: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a) 
@@ -1682,7 +1682,7 @@
 					pkt_dev->saddr_min = in_dev->ifa_list->ifa_address;
 					pkt_dev->saddr_max = pkt_dev->saddr_min;
 				}
-				in_dev_put(in_dev);	
+				__in_dev_put(in_dev);	
 			}
 			rcu_read_unlock();
 		}



 
 > 2. Cliff is getting this with e1000 and pktgen-conf-1-2
 >  looks like calling schedule_timeout with lock held.
 > 
 
Need to reproduce this one...


					--ro
