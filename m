From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] Documentation: net: phy: Add a paragraph about pause frames/flow control
Date: Sun, 27 Nov 2016 10:44:47 -0800
Message-ID: <20161127184449.12351-3-f.fainelli@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34440 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbcK0So5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 13:44:57 -0500
Received: by mail-oi0-f68.google.com with SMTP id m75so10882166oig.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 10:44:56 -0800 (PST)
In-Reply-To: <20161127184449.12351-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Describe that the Ethernet MAC controller is ultimately responsible for
dealing with proper pause frames/flow control advertisement and
enabling, and that it is therefore allowed to have it change
phydev->supported/advertising with SUPPORTED_Pause and
SUPPORTED_AsymPause.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 4b25c0f24201..9a42a9414cea 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -127,8 +127,9 @@ Letting the PHY Abstraction Layer do Everything
  values pruned from them which don't make sense for your controller (a 10/100
  controller may be connected to a gigabit capable PHY, so you would need to
  mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
- for these bitfields. Note that you should not SET any bits, or the PHY may
- get put into an unsupported state.
+ for these bitfields. Note that you should not SET any bits, except the
+ SUPPORTED_Pause and SUPPORTED_AsymPause bits (see below), or the PHY may get
+ put into an unsupported state.
 
  Lastly, once the controller is ready to handle network traffic, you call
  phy_start(phydev).  This tells the PAL that you are ready, and configures the
@@ -139,6 +140,19 @@ Letting the PHY Abstraction Layer do Everything
  When you want to disconnect from the network (even if just briefly), you call
  phy_stop(phydev).
 
+Pause frames / flow control
+
+ The PHY does not participate directly in flow control/pause frames except by
+ making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
+ MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
+ controller supports such a thing. Since flow control/pause frames generation
+ involves the Ethernet MAC driver, it is recommended that this driver takes care
+ of properly indicating advertisement and support for such features by setting
+ the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
+ either before or after phy_connect() and/or as a result of implementing the
+ ethtool::set_pauseparam feature.
+
+
 Keeping Close Tabs on the PAL
 
  It is possible that the PAL's built-in state machine needs a little help to
-- 
2.9.3
