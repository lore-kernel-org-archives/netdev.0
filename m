From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: [PATCH] rfkill: document removal of notifier chain
Date: Wed, 08 Apr 2009 14:37:18 +0100
Message-ID: <49DCA88E.6060400@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Ivo van Doorn <IvDoorn@gmail.com>, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:39008 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765449AbZDHNhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 09:37:23 -0400
Received: by fg-out-1718.google.com with SMTP id e12so43441fga.17
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 06:37:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This unused feature was removed in 4dec9b807be757780ca3611a959ac22c28d292a7

Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
---

p.s. Is netdev really the right list for rfkill (as listed in MAINTAINERS)?
     I have a feeling most development happens on linux-wireless.

 Documentation/rfkill.txt |   23 ++++++++---------------
 1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 4d3ee31..357ef01 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -47,10 +47,8 @@ know when they should enable or disable a wireless network device transmitter.
 This is enabled by the CONFIG_RFKILL Kconfig option.
 
 The rfkill class support makes sure userspace will be notified of all state
-changes on rfkill devices through uevents.  It provides a notification chain
-for interested parties in the kernel to also get notified of rfkill state
-changes in other drivers.  It creates several sysfs entries which can be used
-by userspace.  See section "Userspace support".
+changes on rfkill devices through uevents.  It creates several sysfs entries
+which can be used by userspace.  See section "Userspace support".
 
 The rfkill-input module provides the kernel with the ability to implement a
 basic response when the user presses a key or button (or toggles a switch)
@@ -156,9 +154,8 @@ rfkill class:
 	  transmitter state;
 	* Keeps track of the wireless transmitter state (with help from
 	  the driver);
-	* Generates userspace notifications (uevents) and a call to a
-	  notification chain (kernel) when there is a wireless transmitter
-	  state change;
+	* Generates userspace notifications (uevents) when there is a wireless
+	  transmitter state change;
 	* Connects a wireless communications driver with the common rfkill
 	  control system, which, for example, allows actions such as
 	  "switch all bluetooth devices offline" to be carried out by
@@ -206,18 +203,15 @@ Userspace input handlers (uevents) or kernel input handlers (rfkill-input):
 	  restore the transmitters to their state before the EPO, or unblock
 	  them all.
 
-Userspace uevent handler or kernel platform-specific drivers hooked to the
-rfkill notifier chain:
+Userspace uevent handler or kernel platform-specific drivers:
 
-	* Taps into the rfkill notifier chain or to KOBJ_CHANGE uevents,
-	  in order to know when a device that is registered with the rfkill
-	  class changes state;
+	* Listens to KOBJ_CHANGE uevents or the platform in order to know when
+	  a device that is registered with the rfkill class changes state;
 	* Issues feedback notifications to the user;
 	* In the rare platforms where this is required, synthesizes an input
 	  event to command all *OTHER* rfkill devices to also change their
 	  statues when a specific rfkill device changes state.
 
-
 ===============================================================================
 3: Kernel driver guidelines
 
@@ -269,8 +263,7 @@ SW_RFKILL_ALL, etc) when ALL of the folowing conditions are met:
 When in doubt, do not issue input events.  For drivers that should generate
 input events in some platforms, but not in others (e.g. b43), the best solution
 is to NEVER generate input events in the first place.  That work should be
-deferred to a platform-specific kernel module (which will know when to generate
-events through the rfkill notifier chain) or to userspace.  This avoids the
+deferred to a platform-specific kernel module or to userspace.  This avoids the
 usual maintenance problems with DMI whitelisting.
 
 
-- 
1.5.4.3



