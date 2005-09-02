From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 1/8] orinoco: Stop using "ieee802_11.h".
Date: Thu, 01 Sep 2005 20:01:58 -0400
Message-ID: <1125619318.24497.11.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree 56bfcdb38b3d04c1f8c1fd705e411f4be53b663c (from dee4f325520d4ea29397dd67ca657b7235bb1790)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 18:15:07 2005 -0400

    Stop using "ieee802_11.h".
    
    Use equivalent constants from <net/ieee80211.h>

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -99,11 +99,10 @@
 #include <asm/system.h>
 
 #include "hermes.h"
 #include "hermes_rid.h"
 #include "orinoco.h"
-#include "ieee802_11.h"
 
 /********************************************************************/
 /* Module information                                               */
 /********************************************************************/
 
@@ -148,11 +147,11 @@ MODULE_PARM_DESC(force_monitor, "Allow m
 /* 802.2 LLC/SNAP header used for Ethernet encapsulation over 802.11 */
 static const u8 encaps_hdr[] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
 #define ENCAPS_OVERHEAD		(sizeof(encaps_hdr) + 2)
 
 #define ORINOCO_MIN_MTU		256
-#define ORINOCO_MAX_MTU		(IEEE802_11_DATA_LEN - ENCAPS_OVERHEAD)
+#define ORINOCO_MAX_MTU		(IEEE80211_DATA_LEN - ENCAPS_OVERHEAD)
 
 #define SYMBOL_MAX_VER_LEN	(14)
 #define USER_BAP		0
 #define IRQ_BAP			1
 #define MAX_IRQLOOPS_PER_IRQ	10
@@ -440,11 +439,11 @@ static int orinoco_change_mtu(struct net
 	struct orinoco_private *priv = netdev_priv(dev);
 
 	if ( (new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU) )
 		return -EINVAL;
 
-	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE802_11_HLEN) >
+	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE80211_HLEN) >
 	     (priv->nicbuf_size - ETH_HLEN) )
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
 
@@ -916,11 +915,11 @@ static void __orinoco_ev_rx(struct net_d
 		/* At least on Symbol firmware with PCF we get quite a
                    lot of these legitimately - Poll frames with no
                    data. */
 		return;
 	}
-	if (length > IEEE802_11_DATA_LEN) {
+	if (length > IEEE80211_DATA_LEN) {
 		printk(KERN_WARNING "%s: Oversized frame received (%d bytes)\n",
 		       dev->name, length);
 		stats->rx_length_errors++;
 		goto update_stats;
 	}
@@ -2270,11 +2269,11 @@ static int orinoco_init(struct net_devic
 
 	TRACE_ENTER(dev->name);
 
 	/* No need to lock, the hw_unavailable flag is already set in
 	 * alloc_orinocodev() */
-	priv->nicbuf_size = IEEE802_11_FRAME_LEN + ETH_HLEN;
+	priv->nicbuf_size = IEEE80211_FRAME_LEN + ETH_HLEN;
 
 	/* Initialize the firmware */
 	err = orinoco_reinit_firmware(dev);
 	if (err != 0) {
 		printk(KERN_ERR "%s: failed to initialize firmware (err = %d)\n",


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
