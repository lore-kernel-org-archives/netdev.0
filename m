From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/3] Documentation: networking: update phy.txt with recent changes
Date: Mon, 17 Feb 2014 13:34:04 -0800
Message-ID: <1392672844-1767-4-git-send-email-f.fainelli@gmail.com>
References: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:34937 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbaBQVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:34:32 -0500
In-Reply-To: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library was missing a bunch of newly added PHY driver callbacks
along with a smallish description of what they do, fix that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- fix typo on the soft_reset description

 Documentation/networking/phy.txt | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index ebf2707..e602c6f 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -253,16 +253,25 @@ Writing a PHY driver
 
  Each driver consists of a number of function pointers:
 
+   soft_reset: perform a PHY software reset
    config_init: configures PHY into a sane state after a reset.
      For instance, a Davicom PHY requires descrambling disabled.
    probe: Allocate phy->priv, optionally refuse to bind.
    PHY may not have been reset or had fixups run yet.
    suspend/resume: power management
    config_aneg: Changes the speed/duplex/negotiation settings
+   aneg_done: Determines the auto-negotiation result
    read_status: Reads the current speed/duplex/negotiation settings
    ack_interrupt: Clear a pending interrupt
+   did_interrupt: Checks if the PHY generated an interrupt
    config_intr: Enable or disable interrupts
    remove: Does any driver take-down
+   ts_info: Queries about the HW timestamping status
+   hwtstamp: Set the PHY HW timestamping configuration
+   rxtstamp: Requests a receive timestamp at the PHY level for a 'skb'
+   txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'
+   set_wol: Enable Wake-on-LAN at the PHY level
+   get_wol: Get the Wake-on-LAN status at the PHY level
 
  Of these, only config_aneg and read_status are required to be
  assigned by the driver code.  The rest are optional.  Also, it is
-- 
1.8.3.2
