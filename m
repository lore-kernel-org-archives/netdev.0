From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v4 3/3] Documentation: networking: phy.txt: Update text for indirect MMD access
Date: Sun, 29 Jun 2014 20:35:24 -0500
Message-ID: <1404092124-18704-4-git-send-email-vbridgers2013@gmail.com>
References: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: f.fainelli@gmail.com, rdunlap@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:43094 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbaF3BjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:20 -0400
Received: by mail-oa0-f46.google.com with SMTP id m1so7980965oag.5
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 18:39:20 -0700 (PDT)
In-Reply-To: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the PHY library documentation to describe how a specific PHY
driver can use the PAL MMD register access routines or override those
routines with it's own in the event the PHY does not support the IEEE
standard for reading and writing MMD phy registers.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V4: None
V3: Add modified Documentation/networking/phy.txt per review comments.
---
 Documentation/networking/phy.txt |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 3544c98..326836a 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -272,6 +272,8 @@ Writing a PHY driver
    txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'
    set_wol: Enable Wake-on-LAN at the PHY level
    get_wol: Get the Wake-on-LAN status at the PHY level
+   rd_mmd_indirect: Read PHY MMD indirect register
+   wr_mmd_indirect: Write PHY MMD indirect register
 
  Of these, only config_aneg and read_status are required to be
  assigned by the driver code.  The rest are optional.  Also, it is
@@ -284,7 +286,21 @@ Writing a PHY driver
 
  Feel free to look at the Marvell, Cicada, and Davicom drivers in
  drivers/net/phy/ for examples (the lxt and qsemi drivers have
- not been tested as of this writing)
+ not been tested as of this writing).
+
+ The PHY's MMD register accesses are handled by the PAL framework
+ by default, but can be overridden by a specific PHY driver if
+ required. This could be the case if a PHY was released for
+ manufacturing before the MMD PHY register definitions were
+ standardized by the IEEE. Most modern PHYs will be able to use
+ the generic PAL framework for accessing the PHY's MMD registers.
+ An example of such usage is for Energy Efficient Ethernet support,
+ implemented in the PAL. This support uses the PAL to access MMD
+ registers for EEE query and configuration if the PHY supports
+ the IEEE standard access mechanisms, or can use the PHY's specific
+ access interfaces if overridden by the specific PHY driver. See
+ the Micrel driver in drivers/net/phy/ for an example of how this
+ can be implemented.
 
 Board Fixups
 
-- 
1.7.9.5
