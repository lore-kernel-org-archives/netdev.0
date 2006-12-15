From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] rt2x00: Fix PKT_PROBE_RESP breakage
Date: Fri, 15 Dec 2006 20:39:20 +0100
Message-ID: <200612152039.20635.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Linville, John" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46543
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbWLOTkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:40:15 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix breakage from removal of PKT_PROBE_RESP.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-15 19:43:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-15 19:43:14.000000000 +0100
@@ -1427,8 +1427,11 @@ static void rt2400pci_write_tx_desc(stru
 	 * Beacons and probe responses require the tsf timestamp
 	 * to be inserted into the frame.
 	 */
-	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
+		req_timestamp = 1;
+	if ((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
+		req_timestamp = 1;
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-15 19:43:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-15 19:43:14.000000000 +0100
@@ -1568,8 +1568,11 @@ static void rt2500pci_write_tx_desc(stru
 	 * Beacons and probe responses require the tsf timestamp
 	 * to be inserted into the frame.
 	 */
-	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
+		req_timestamp = 1;
+	if ((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
+		req_timestamp = 1;
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-15 19:43:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-15 19:43:14.000000000 +0100
@@ -1539,8 +1539,11 @@ static void rt2500usb_write_tx_desc(stru
 	 * Beacons and probe responses require the tsf timestamp
 	 * to be inserted into the frame.
 	 */
-	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
+		req_timestamp = 1;
+	if ((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
+		req_timestamp = 1;
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-15 19:44:13.000000000 +0100
@@ -2023,8 +2023,11 @@ static void rt61pci_write_tx_desc(struct
 	 * Beacons and probe responses require the tsf timestamp
 	 * to be inserted into the frame.
 	 */
-	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
+		req_timestamp = 1;
+	if ((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
+		req_timestamp = 1;
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-15 19:46:11.000000000 +0100
@@ -1802,8 +1802,11 @@ static void rt73usb_write_tx_desc(struct
 	 * Beacons and probe responses require the tsf timestamp
 	 * to be inserted into the frame.
 	 */
-	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
+		req_timestamp = 1;
+	if ((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
+		req_timestamp = 1;
 
 	/*
 	 * Determine with what IFS priority this frame should be send.

-- 
Greetings Michael.
