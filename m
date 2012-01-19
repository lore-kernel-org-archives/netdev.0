From: "Bishop, Mark" <Mark.Bishop@cooperindustries.com>
Subject: SMSC9215 Issue
Date: Thu, 19 Jan 2012 15:55:27 -0500
Message-ID: <5D308BD40154E4439D82454FE483A50205BB46AD@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooperlighting-sw.cooperlighting.com ([216.130.131.68]:26805
	"EHLO cooperlighting-sw.cooperlighting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932718Ab2ASU4X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 15:56:23 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having an issue interfacing my uClinux platform with a SMSC9215.

The part doesn't have link with the Micrel KSZ8995 it is attached too
before it tries to execute smsc911x_phy_check_loopbackpkt() in
smsc911x.x  

I'm not using the external PHY:

static struct smsc911x_platform_config smsc911x_config = {
        .flags = SMSC911X_USE_16BIT|SMSC911X_FORCE_INTERNAL_PHY ,


The polling driver works just fine in my uboot, but the interrupt driver
in linux is causing me issues.  

smsc911x: Driver version 2008-10-21.
eth%d: smsc911x_init: Driver Parameters:
eth%d: smsc911x_init: LAN base: 0x24000000
eth%d: smsc911x_init: IRQ: 258
eth%d: smsc911x_init: PHY will be autodetected.
eth%d: smsc911x_init: BYTE_TEST: 0x87654321
eth%d: smsc911x_init: LAN911x identified, idrev: 0x115A0000, generation:
3
eth0: smsc911x_drv_probe: Network interface: "eth0"
eth0: smsc911x_phy_initialise_external: Forcing internal PHY
smsc911x-mdio: probed
eth0: smsc911x_mii_probe: PHY 0: addr 1, phy_id 0x0007C0C3
eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=0:01, irq=-1)
eth0: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopback
test
eth0: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopback
test
eth0: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopback
test
eth0: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopback
test
eth0: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopback
test
.....
eth0: smsc911x_mii_probe: Failed Loop Back Test
eth0: smsc911x_mii_init: Error registering mii bus2
eth0: smsc911x_drv_probe: Error -6 initialising mii
