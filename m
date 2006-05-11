From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] rt2x00: fix oops in config_interface
Date: Thu, 11 May 2006 17:06:42 +0200
Message-ID: <20060511170642.3d03f46d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44424 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751837AbWEKPGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 11:06:44 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BSSID passed to config_interface callback is NULL in modes other than STA or
IBSS.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 drivers/net/wireless/d80211/rt2x00/rt2400pci.c |    3 ++-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c |    3 ++-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c |    3 ++-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c   |    3 ++-
 drivers/net/wireless/d80211/rt2x00/rt73usb.c   |    3 ++-
 5 files changed, 10 insertions(+), 5 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1848,7 +1848,8 @@ rt2400pci_config_interface(struct net_de
 	if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
 
-	rt2400pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid)
+		rt2400pci_config_bssid(rt2x00pci, conf->bssid);
 
 	return 0;
 }
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1971,7 +1971,8 @@ rt2500pci_config_interface(struct net_de
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
 
-	rt2500pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid)
+		rt2500pci_config_bssid(rt2x00pci, conf->bssid);
 
 	return 0;
 }
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1636,7 +1636,8 @@ rt2500usb_config_interface(struct net_de
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
 
-	rt2500usb_config_bssid(rt2x00usb, conf->bssid);
+	if (conf->bssid)
+		rt2500usb_config_bssid(rt2x00usb, conf->bssid);
 
 	return 0;
 }
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2434,7 +2434,8 @@ rt61pci_config_interface(struct net_devi
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
 
-	rt61pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid)
+		rt61pci_config_bssid(rt2x00pci, conf->bssid);
 
 	return 0;
 }
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1935,7 +1935,8 @@ rt73usb_config_interface(struct net_devi
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
 
-	rt73usb_config_bssid(rt2x00usb, conf->bssid);
+	if (conf->bssid)
+		rt73usb_config_bssid(rt2x00usb, conf->bssid);
 
 	return 0;
 }


-- 
Jiri Benc
SUSE Labs
