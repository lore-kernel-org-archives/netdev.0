From: Peter Bieringer <pb@bieringer.de>
Subject: Hardcoding instead of using MAX_UNITS in 3c590.c driver
Date: Sun, 17 Aug 2003 14:03:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <45450000.1061121818@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

during looking for some "how-would-this-be-done" code, I wonder that driver
3c590.c doesn't always use MAX_UNITS. In difference, ne2.c does.

Perhaps fix below would helps. Possible, that such inconsistency also
exists in other drivers, too:

# diff -u 3c59x.c.orig 3c59x.c
--- 3c59x.c.orig        Sun Aug 17 13:57:29 2003
+++ 3c59x.c     Sun Aug 17 13:58:45 2003
@@ -269,12 +269,13 @@
                                        DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");

+#define MAX_UNITS 8
 MODULE_PARM(debug, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(hw_checksums, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(flow_ctrl, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(enable_wol, "1-" __MODULE_STRING(8) "i");
+MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(hw_checksums, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(flow_ctrl, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(enable_wol, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM(compaq_ioaddr, "i");
@@ -847,7 +848,6 @@


 /* This driver uses 'options' to pass the media type, full-duplex flag,
etc. */
 /* Option count limit only -- unlimited interfaces are supported. */
-#define MAX_UNITS 8
 static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};


BTW:
- static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
+ static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1};

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
