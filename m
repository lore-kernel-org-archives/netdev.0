From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] br2684 - build problems on 2.6.0-test5
Date: Tue, 9 Sep 2003 16:00:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030909160019.0a4ea902.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't know if chas already fixed this..

diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Tue Sep  9 15:59:18 2003
+++ b/net/atm/br2684.c	Tue Sep  9 15:59:18 2003
@@ -732,9 +732,10 @@
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 #define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
 #define bs(var)		b1(var, 0), b1(var, 1), b1(var, 2), b1(var, 3)
-			if (brvcc->filter.netmask != 0 && pos-- == 0)
-				return sprintf(buf, "    filter=%d.%d.%d.%d/"
-				    "%d.%d.%d.%d\n", bs(prefix), bs(netmask));
+
+			if (brvcc->filter.netmask != 0)
+				seq_printf(seq, "    filter=%d.%d.%d.%d/"
+					   "%d.%d.%d.%d\n", bs(prefix), bs(netmask));
 #undef bs
 #undef b1
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
