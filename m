From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] let BT_HIDP depend on INPUT
Date: Mon, 10 Jul 2006 20:31:54 +0200
Message-ID: <20060710183154.GD13938@stusta.de>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bluez-devel@lists.sf.net, linux390@de.ibm.com
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
To: marcel@holtmann.org, maxk@qualcomm.com
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch let's BT_HIDP depend on instead of select INPUT.

This fixes the following warning during an s390 build:

<--  snip  -->

...
net/bluetooth/hidp/Kconfig:4:warning: 'select' used by config symbol 'BT_HIDP' refer to undefined symbol 'INPUT'
...

<--  snip  -->

A dependency on INPUT also implies !S390 (and therefore makes the 
explicit dependency obsolete) since INPUT is not available on s390.

The practical difference should be nearly zero, since INPUT is always 
set to y unless EMBEDDED=y (or S390=y).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.18-rc1-mm1-full/net/bluetooth/hidp/Kconfig.old	2006-07-10 16:51:59.000000000 +0200
+++ linux-2.6.18-rc1-mm1-full/net/bluetooth/hidp/Kconfig	2006-07-10 16:52:52.000000000 +0200
@@ -1,7 +1,6 @@
 config BT_HIDP
 	tristate "HIDP protocol support"
-	depends on BT && BT_L2CAP && (BROKEN || !S390)
-	select INPUT
+	depends on INPUT && BT && BT_L2CAP
 	help
 	  HIDP (Human Interface Device Protocol) is a transport layer
 	  for HID reports.  HIDP is required for the Bluetooth Human



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
