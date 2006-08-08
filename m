From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 4/6] rt2x00 - txpower limits
Date: Tue, 8 Aug 2006 15:46:56 +0200
Message-ID: <200608081546.56632.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:39914 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964885AbWHHNr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:27 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175918nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:26 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also check for equality with txpower limits.
It doesn't do any harm, but it does prevent compiler
warnings in certain conditions.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-08 15:05:04.000000000 +0200
@@ -881,8 +881,8 @@
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
 		(__txpower) += MIN_TXPOWER; \
-		((__txpower) < MIN_TXPOWER) ? MAX_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MIN_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MAX_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MIN_TXPOWER : \
 		(MAX_TXPOWER - ((__txpower) - MIN_TXPOWER))); \
 	})
 
diff -rU3 wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-08 15:05:16.000000000 +0200
@@ -1142,8 +1142,8 @@
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff -rU3 wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-08 15:05:27.000000000 +0200
@@ -679,8 +679,8 @@
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff -rU3 wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-08 15:05:36.000000000 +0200
@@ -1360,8 +1360,8 @@
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff -rU3 wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-08 15:05:44.000000000 +0200
@@ -939,8 +939,8 @@
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
