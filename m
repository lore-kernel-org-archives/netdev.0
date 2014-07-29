From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v5 3/3] Documentation: networking: phy.txt: Update text for indirect MMD access
Date: Tue, 29 Jul 2014 15:19:59 -0500
Message-ID: <1406665199-18174-4-git-send-email-vbridgers2013@gmail.com>
References: <1406665199-18174-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: f.fainelli@gmail.com, rdunlap@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57044 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbaG2UXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 16:23:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so203253pab.28
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 13:23:43 -0700 (PDT)
In-Reply-To: <1406665199-18174-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the PHY library documentation to describe how a specific PHY
driver can use the PAL MMD register access routines or override those
routines with it's own in the event the PHY does not support the IEEE
standard for reading and writing MMD phy registers.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
V5: Change rd/wr_mmd_indirect to read/write_mmd_indirect per
    round of last review comments
V4: None
V3: Update Documentation/networking/phy.txt per review comments.
V2: None, this patch not present
---
 Documentation/networking/phy.txt |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 3544c98..e839e7e 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -272,6 +272,8 @@ Writing a PHY driver
    txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'
    set_wol: Enable Wake-on-LAN at the PHY level
    get_wol: Get the Wake-on-LAN status at the PHY level
+   read_mmd_indirect: Read PHY MMD indirect register
+   write_mmd_indirect: Write PHY MMD indirect register
 
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
