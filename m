From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/8] gigaset: documentation update
Date: Thu, 14 May 2009 00:44:17 +0200 (CEST)
Message-ID: <20090514-patch-01.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:38970 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbZEMWoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:32 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mention handling of unregisteted DECT wireless datasets in README.gigaset.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index 02c0e93..f6e9eaa 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -192,7 +192,6 @@ GigaSet 307x Device Driver
 
 2.6. M105 Undocumented USB Requests
      ------------------------------
-
      The Gigaset M105 USB data box understands a couple of useful, but
      undocumented USB commands. These requests are not used in normal
      operation (for wireless access to the base), but are needed for access
@@ -204,6 +203,20 @@ GigaSet 307x Device Driver
      M105, try setting that option to "y" via 'make {x,menu}config' and
      recompiling the driver.
 
+2.7. Unregistered Wireless Devices (M101/M105)
+     -----------------------------------------
+     The main purpose of the ser_gigaset and usb_gigaset drivers is to allow
+     the M101 and M105 wireless devices to be used as ISDN devices for ISDN
+     connections through a Gigaset base. Therefore they assume that the device
+     is registered to a DECT base.
+
+     If the M101/M105 device is not registered to a base, initialization of
+     the device fails, and a corresponding error message is logged by the
+     driver. In that situation, a restricted set of functions is available
+     which includes, in particular, those necessary for registering the device
+     to a base or for switching it between Fixed Part and Portable Part
+     modes. For the M105, these commands require the "Support for undocumented
+     USB requests" configuration option (see section 2.6.) to be enabled.
 
 3.   Troubleshooting
      ---------------
@@ -240,6 +253,14 @@ GigaSet 307x Device Driver
         Recompile the usb_gigaset driver with the kernel configuration option
         CONFIG_GIGASET_UNDOCREQ set to 'y'. (see section 2.6.)
 
+     Problem:
+	Messages like this:
+	    usb_gigaset 3-2:1.0: Could not initialize the device.
+	appear in your syslog.
+     Solution:
+	Check whether your M10x wireless device is correctly registered to the
+	Gigaset base. (see section 2.7.)
+
 3.2. Telling the driver to provide more information
      ----------------------------------------------
      Building the driver with the "Gigaset debugging" kernel configuration
-- 
1.6.2.1.214.ge986c

