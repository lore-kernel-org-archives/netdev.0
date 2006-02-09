From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/7] IrDA: Set proper IrLAP device address length
Date: Thu, 9 Feb 2006 23:32:16 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0602090323140.19426@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This patch set IrDA's addr_len properly, i.e to 4 bytes, the size of the
IrLAP device address.

Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/include/net/irda/irlap.h b/include/net/irda/irlap.h
index f55e86e..2127cae 100644
--- a/include/net/irda/irlap.h
+++ b/include/net/irda/irlap.h
@@ -50,6 +50,9 @@
 /* May be different when we get VFIR */
 #define LAP_MAX_HEADER (LAP_ADDR_HEADER + LAP_CTRL_HEADER)

+/* Each IrDA device gets a random 32 bits IRLAP device address */
+#define LAP_ALEN 4
+
 #define BROADCAST  0xffffffff /* Broadcast device address */
 #define CBROADCAST 0xfe       /* Connection broadcast address */
 #define XID_FORMAT 0x01       /* Discovery XID format */
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 890bac0..e3debbd 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -343,12 +343,12 @@ static void irda_task_timer_expired(void
 static void irda_device_setup(struct net_device *dev)
 {
         dev->hard_header_len = 0;
-        dev->addr_len        = 0;
+        dev->addr_len        = LAP_ALEN;

         dev->type            = ARPHRD_IRDA;
         dev->tx_queue_len    = 8; /* Window size + 1 s-frame */

-	memset(dev->broadcast, 0xff, 4);
+	memset(dev->broadcast, 0xff, LAP_ALEN);

 	dev->mtu = 2048;
 	dev->flags = IFF_NOARP;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
