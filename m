From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/2] rt2x00: fix breakage after pkt_type field was removed
Date: Wed, 13 Dec 2006 18:00:36 +0100 (CET)
Message-ID: <20061213170036.E313D3AA7EF@silver.suse.cz>
References: <20061213180032.241265000.midnight@suse.cz>
Cc: netdev@vger.kernel.org, Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44735 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965032AbWLMQ4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 11:56:06 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213180032.241265000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix breakage after pkt_type field was removed from ieee80211_tx_control.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2x00.h    |    3 +++
 drivers/net/wireless/d80211/rt2x00/rt61pci.c   |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt73usb.c   |    2 +-
 6 files changed, 8 insertions(+), 5 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1428,7 +1428,7 @@ static void rt2400pci_write_tx_desc(stru
 	 * to be inserted into the frame.
 	 */
 	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+			   is_probe_resp(frame_control));
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1569,7 +1569,7 @@ static void rt2500pci_write_tx_desc(stru
 	 * to be inserted into the frame.
 	 */
 	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+			   is_probe_resp(frame_control));
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1540,7 +1540,7 @@ static void rt2500usb_write_tx_desc(stru
 	 * to be inserted into the frame.
 	 */
 	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+			   is_probe_resp(frame_control));
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -130,6 +130,9 @@ static int rt2x00_debug_level = 0;
 #define is_rts_frame(__fc) \
 	( !!((((__fc) &  IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) && \
 	     (((__fc) &  IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)) )
+#define is_probe_resp(__fc) \
+	( !!((((__fc) & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT) && \
+	     (((__fc) & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)) )
 
 /*
  * TX result flags.
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2024,7 +2024,7 @@ static void rt61pci_write_tx_desc(struct
 	 * to be inserted into the frame.
 	 */
 	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+			   is_probe_resp(frame_control));
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1803,7 +1803,7 @@ static void rt73usb_write_tx_desc(struct
 	 * to be inserted into the frame.
 	 */
 	req_timestamp = !!(control->queue == IEEE80211_TX_QUEUE_BEACON ||
-		  	   control->pkt_type == PKT_PROBE_RESP);
+			   is_probe_resp(frame_control));
 
 	/*
 	 * Determine with what IFS priority this frame should be send.
