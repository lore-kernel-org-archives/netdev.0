From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify themselves as Ethernet switches
Date: Wed, 29 Apr 2015 18:57:39 -0700
Message-ID: <1430359064-23454-4-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34815 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbD3B6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:04 -0400
Received: by pacyx8 with SMTP id yx8so44621849pac.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:04 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet MAC drivers using the PHY library require the hardcoding
of link parameters when interfaced to a switch device. This has
typically lead to various ad-hoc implementations looking like this:

- using a "fixed PHY" emulated device, which will provide link
  indication towards the Ethernet MAC driver and hardware

- pretend there is no PHY and hardcode link parameters, ala mv643x_eth

Based on that, it is desireable to have the PHY drivers advertise the
correct link parameters, just like regular Ethernet PHYs towards their
CPU Ethernet MAC drivers, however, Ethernet MAC drivers should be able
to tell whether this link should be monitored or not. In the context of
an Ethernet switch, we do not need to monitor this link since it should
be always up.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 685809835b5c..52fc64874fdb 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -327,6 +327,7 @@ struct phy_c45_device_ids {
  * c45_ids: 802.3-c45 Device Identifers if is_c45.
  * is_c45:  Set to true if this phy uses clause 45 addressing.
  * is_internal: Set to true if this phy is internal to a MAC.
+ * is_switch: Set to true if this phy is an Ethernet switch.
  * has_fixups: Set to true if this phy has fixups/quirks.
  * suspended: Set to true if this phy has been suspended successfully.
  * state: state of the PHY for management purposes
@@ -365,6 +366,7 @@ struct phy_device {
 	struct phy_c45_device_ids c45_ids;
 	bool is_c45;
 	bool is_internal;
+	bool is_switch;
 	bool has_fixups;
 	bool suspended;
 
@@ -675,6 +677,16 @@ static inline bool phy_is_internal(struct phy_device *phydev)
 }
 
 /**
+ * phy_is_ethswitch - Convenience function for testing if this PHY is the
+ * CPU port facing side of an Ethernet switch
+ * @phydev: the phy_device struct
+ */
+static inline bool phy_is_ethswitch(struct phy_device *phydev)
+{
+	return phydev->is_switch;
+}
+
+/**
  * phy_write_mmd - Convenience function for writing a register
  * on an MMD on a given PHY.
  * @phydev: The phy_device struct
-- 
2.1.0
