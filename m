From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: [PATCH] drivers/net/wireless/d80211: Check configuration type in
 hw->config_interface.
Date: Wed, 19 Jul 2006 22:26:52 +0200
Message-ID: <44BE958C.4030401@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:61704 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S1030276AbWGSU04
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 16:26:56 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch prevents a NULL pointer dereferencing in AP mode:
ieee80211_if_config will set conf->bssid only if device is of type STA 
or IBSS.
I see it using following commands right after module loading (with rt61)
# iwconfig wlan0 mode Master
# ifconfig wlan0 up


Signed-off-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>


 adm8211/adm8211.c  |    4 +++-
 rt2x00/rt2400pci.c |    4 +++-
 rt2x00/rt2500pci.c |    4 +++-
 rt2x00/rt61pci.c   |    4 +++-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c 
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 9fc5da7..53f05c2 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -1469,7 +1469,9 @@ static int adm8211_config_interface(stru
 {
     struct adm8211_priv *priv = ieee80211_dev_hw_data(dev);
 
-    if (memcmp(conf->bssid, priv->bssid, ETH_ALEN)) {
+    if ((conf->type == IEEE80211_IF_TYPE_STA ||
+         conf->type == IEEE80211_IF_TYPE_IBSS) &&
+         memcmp(conf->bssid, priv->bssid, ETH_ALEN)) {
         adm8211_set_bssid(dev, conf->bssid);
         memcpy(priv->bssid, conf->bssid, ETH_ALEN);
     }
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 946cf86..1d45851 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1877,7 +1877,9 @@ rt2400pci_config_interface(struct net_de
     if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
         return 0;
 
-    rt2400pci_config_bssid(rt2x00pci, conf->bssid);
+    if (conf->type == IEEE80211_IF_TYPE_STA ||
+        conf->type == IEEE80211_IF_TYPE_IBSS)
+        rt2400pci_config_bssid(rt2x00pci, conf->bssid);
 
     return 0;
 }
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index ca0edd5..8d2b3a7 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -2000,7 +2000,9 @@ rt2500pci_config_interface(struct net_de
     if (conf->type == IEEE80211_IF_TYPE_MNTR)
         return 0;
 
-    rt2500pci_config_bssid(rt2x00pci, conf->bssid);
+    if (conf->type == IEEE80211_IF_TYPE_STA ||
+        conf->type == IEEE80211_IF_TYPE_IBSS)
+        rt2500pci_config_bssid(rt2x00pci, conf->bssid);
 
     return 0;
 }
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 0799f9f..47b2eaf 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2463,7 +2463,9 @@ rt61pci_config_interface(struct net_devi
     if (conf->type == IEEE80211_IF_TYPE_MNTR)
         return 0;
 
-    rt61pci_config_bssid(rt2x00pci, conf->bssid);
+    if (conf->type == IEEE80211_IF_TYPE_STA ||
+        conf->type == IEEE80211_IF_TYPE_IBSS)
+        rt61pci_config_bssid(rt2x00pci, conf->bssid);
 
     return 0;
 }


