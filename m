From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] switchdev: Use switch ID in suggested udev rule
Date: Tue,  5 Apr 2016 10:20:03 +0200
Message-ID: <1459844404-4698-3-git-send-email-jiri@resnulli.us>
References: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36136 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499AbcDEIUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:20:11 -0400
Received: by mail-wm0-f46.google.com with SMTP id 127so15721890wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 01:20:10 -0700 (PDT)
In-Reply-To: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since there can be multiple switch ASICs on the same system we should
use the switch ID in order to differentiate between them and set the
switch name (e.g. swX) accordingly.

Also, replace the order of the "Switch ID" and "Port Netdev Naming"
sections following the above change.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 2f65912..31c3911 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -89,6 +89,18 @@ Typically, the management port is not participating in offloaded data plane and
 is loaded with a different driver, such as a NIC driver, on the management port
 device.
 
+Switch ID
+^^^^^^^^^
+
+The switchdev driver must implement the switchdev op switchdev_port_attr_get
+for SWITCHDEV_ATTR_ID_PORT_PARENT_ID for each port netdev, returning the same
+physical ID for each port of a switch.  The ID must be unique between switches
+on the same system.  The ID does not need to be unique between switches on
+different systems.
+
+The switch ID is used to locate ports on a switch and to know if aggregated
+ports belong to the same switch.
+
 Port Netdev Naming
 ^^^^^^^^^^^^^^^^^^
 
@@ -104,25 +116,13 @@ external configuration.  For example, if a physical 40G port is split logically
 into 4 10G ports, resulting in 4 port netdevs, the device can give a unique
 name for each port using port PHYS name.  The udev rule would be:
 
-SUBSYSTEM=="net", ACTION=="add", DRIVER="<driver>", ATTR{phys_port_name}!="", \
-	NAME="$attr{phys_port_name}"
+SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
+	ATTR{phys_port_name}!="", NAME="swX$attr{phys_port_name}"
 
 Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
 is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
 would be sub-port 0 on port 1 on switch 1.
 
-Switch ID
-^^^^^^^^^
-
-The switchdev driver must implement the switchdev op switchdev_port_attr_get
-for SWITCHDEV_ATTR_ID_PORT_PARENT_ID for each port netdev, returning the same
-physical ID for each port of a switch.  The ID must be unique between switches
-on the same system.  The ID does not need to be unique between switches on
-different systems.
-
-The switch ID is used to locate ports on a switch and to know if aggregated
-ports belong to the same switch.
-
 Port Features
 ^^^^^^^^^^^^^
 
-- 
2.5.5
