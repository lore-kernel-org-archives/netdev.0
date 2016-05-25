From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 3/3] Documentation: networking: dsa: Describe port_vlan_filtering
Date: Tue, 24 May 2016 21:26:41 -0700
Message-ID: <1464150401-2318-4-git-send-email-f.fainelli@gmail.com>
References: <1464150401-2318-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, idosch@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33367 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcEYE0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 00:26:51 -0400
Received: by mail-oi0-f68.google.com with SMTP id m198so8616823oig.0
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 21:26:51 -0700 (PDT)
In-Reply-To: <1464150401-2318-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Described what the port_vlan_filtering function is supposed to
accomplish.

Fixes: fb2dabad69f0 ("net: dsa: support VLAN filtering switchdev attr")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/dsa/dsa.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 411b57fd73aa..9d05ed7f7da5 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -535,6 +535,16 @@ Bridge layer
 Bridge VLAN filtering
 ---------------------
 
+- port_vlan_filtering: bridge layer function invoked when the bridge gets
+  configured for turning on or off VLAN filtering. If nothing specific needs to
+  be done at the hardware level, this callback does not need to be implemented.
+  When VLAN filtering is turned on, the hardware must be programmed with
+  rejecting 802.1Q frames which have VLAN IDs outside of the programmed allowed
+  VLAN ID map/rules.  If there is no PVID programmed into the switch port,
+  untagged frames must be rejected as well. When turned off the switch must
+  accept any 802.1Q frames irrespective of their VLAN ID, and untagged frames are
+  allowed.
+
 - port_vlan_prepare: bridge layer function invoked when the bridge prepares the
   configuration of a VLAN on the given port. If the operation is not supported
   by the hardware, this function should return -EOPNOTSUPP to inform the bridge
-- 
2.7.4
