From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH RFC] phylib EEE updates
Date: Fri, 24 Mar 2017 11:14:11 +0000
Message-ID: <20170324111411.GD7909@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45788 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdCXLOm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 07:14:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,

This series of patches depends on the previous set of changes, and is
therefore net-next material.

While testing the EEE code, I discovered a number of issues:

1. It is possible to enable advertisment of EEE modes which are not
   supported by the hardware.  We omit to check the supported modes
   and mask off those modes that are not supported before writing the
   EEE advertisment register.

2. We need to restart autonegotiation after a change of the EEE
   advertisment, otherwise the link partner does not see the updated
   EEE modes.

3. SGMII connected PHYs are also capable of supporting EEE.

I'm not too sure why we have the test in phylib for the interface mode,
as the list of interface modes that support EEE is likely to increase
(eg, 10G interface modes have provision to support EEE mode.)  I did
think about killing the test, but the older interface modes probably
don't support it.  Any thoughts on what to do about that - maybe the
test should be reversed to exclude those modes which definitely don't
support EEE?

 drivers/net/phy/phy.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)
   
-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
