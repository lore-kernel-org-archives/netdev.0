From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] pcnet32: use unsigned 1-bit fields
Date: Sun, 10 Oct 2004 15:44:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4169BB5E.1070409@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000100080406080802080101"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, jgarzik <jgarzik@pobox.com>,
        tsbogend@alpha.franken.de, brazilnut@us.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000100080406080802080101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


1-bit fields should be unsigned.  Keeps sparse happy,
keeps gcc straight.

~Randy


--------------000100080406080802080101
Content-Type: text/x-patch;
 name="pcnet32_bits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcnet32_bits.patch"


Fix sparse warning and tell gcc that 1-bit fields are unsigned.
drivers/net/pcnet32.c:362:21: warning: dubious one-bit signed bitfield

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/pcnet32.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -Naurp ./drivers/net/pcnet32.c~pcnet_bits ./drivers/net/pcnet32.c
--- ./drivers/net/pcnet32.c~pcnet_bits	2004-08-13 22:36:33.000000000 -0700
+++ ./drivers/net/pcnet32.c	2004-10-10 15:23:07.964797120 -0700
@@ -359,9 +359,9 @@ struct pcnet32_private {
     struct net_device_stats stats;
     char		tx_full;
     int			options;
-    int	shared_irq:1,			/* shared irq possible */
-	dxsuflo:1,			/* disable transmit stop on uflo */
-	mii:1;				/* mii port available */
+    unsigned int	shared_irq:1,	/* shared irq possible */
+			dxsuflo:1,	/* disable transmit stop on uflo */
+			mii:1;		/* mii port available */
     struct net_device	*next;
     struct mii_if_info	mii_if;
     struct timer_list	watchdog_timer;


--------------000100080406080802080101--
