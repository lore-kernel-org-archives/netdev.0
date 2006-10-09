From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 2/3] d80211: remove poorly documented ieee80211_hw extra_hdr_room flag
Date: Mon, 9 Oct 2006 10:03:06 -0700
Message-ID: <20061009170306.GB27239@devicescape.com>
References: <20061009170159.804032000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:23202 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S932943AbWJIRDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 13:03:07 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="remove-extra_hdr_room.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This flag is unused by all in tree drivers.  Furthermore, the way that
it is documented is not consistent with the way it is actually used by
ieee80211.c.  The original attempt appears to be something to do with
adding extra header room for low-level drivers which need to pad the
IEEE 802.11 header (example: Atheros).

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -476,10 +476,6 @@ struct ieee80211_hw {
 	/* Force software encryption for TKIP packets if WMM is enabled. */
 	unsigned int no_tkip_wmm_hwaccel:1;
 
-	/* set if the payload needs to be padded at even boundaries after the
-	 * header */
-	unsigned int extra_hdr_room:1;
-
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets passed up. device_strips_mic must be set
 	 * for such devices. The 'encryption' frame control bit is expected to
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -1551,7 +1551,7 @@ static int ieee80211_subif_start_xmit(st
 	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
 	 * alloc_skb() (net/core/skbuff.c)
 	 */
-	head_need = hdrlen + encaps_len + (local->hw->extra_hdr_room ? 2 : 0);
+	head_need = hdrlen + encaps_len;
 	head_need -= skb_headroom(skb);
 
 	/* We are going to modify skb data, so make a copy of it if happens to
Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2018,7 +2018,6 @@ static int __devinit adm8211_probe(struc
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 0;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 0;
 	hw->fraglist = 0;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -2578,7 +2578,6 @@ static int rt2400pci_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -2732,7 +2732,6 @@ static int rt2500pci_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -2419,7 +2419,6 @@ static int rt2500usb_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -3252,7 +3252,6 @@ static int rt61pci_init_hw(struct rt2x00
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -2792,7 +2792,6 @@ static int rt73usb_init_hw(struct rt2x00
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;

--
