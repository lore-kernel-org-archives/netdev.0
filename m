From: sfeldma@gmail.com
Subject: [PATCH net-next 7/7] switchdev: update documentation on FDB ageing_time
Date: Fri, 18 Sep 2015 12:55:51 -0700
Message-ID: <1442606151-50429-8-git-send-email-sfeldma@gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33066 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbIRTxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:53:15 -0400
Received: by pacex6 with SMTP id ex6so59217481pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 12:53:14 -0700 (PDT)
In-Reply-To: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 476df04..67e43ee 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -239,20 +239,20 @@ The driver should initialize the attributes to the hardware defaults.
 FDB Ageing
 ^^^^^^^^^^
 
-There are two FDB ageing models supported: 1) ageing by the device, and 2)
-ageing by the kernel.  Ageing by the device is preferred if many FDB entries
-are supported.  The driver calls call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
-...) to age out the FDB entry.  In this model, ageing by the kernel should be
-turned off.  XXX: how to turn off ageing in kernel on a per-port basis or
-otherwise prevent the kernel from ageing out the FDB entry?
-
-In the kernel ageing model, the standard bridge ageing mechanism is used to age
-out stale FDB entries.  To keep an FDB entry "alive", the driver should refresh
-the FDB entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
+The bridge will skip ageing FDB entries marked with NTF_EXT_LEARNED and it is
+the responsibility of the port driver/device to age out these entries.  If the
+port device supports ageing, when the FDB entry expires, it will notify the
+driver which in turn will notify the bridge with SWITCHDEV_FDB_DEL.  If the
+device does not support ageing, the driver can simulate ageing using a
+garbage collection timer to monitor FBD entries.  Expired entries will be
+notified to the bridge using SWITCHDEV_FDB_DEL.  See rocker driver for
+example of driver running ageing timer.
+
+To keep an NTF_EXT_LEARNED entry "alive", the driver should refresh the FDB
+entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
 notification will reset the FDB entry's last-used time to now.  The driver
 should rate limit refresh notifications, for example, no more than once a
-second.  If the FDB entry expires, fdb_delete is called to remove entry from
-the device.
+second.  (The last-used time is visible using the bridge -s fdb option).
 
 STP State Change on Port
 ^^^^^^^^^^^^^^^^^^^^^^^^
-- 
1.7.10.4
