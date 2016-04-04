From: Petr Kulhavy <petr@barix.com>
Subject: davinci-mdio: failing to connect to PHY
Date: Mon, 4 Apr 2016 10:18:30 +0200
Message-ID: <57022356.6010309@barix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:36670 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbcDDISc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 04:18:32 -0400
Received: by mail-lf0-f41.google.com with SMTP id g184so83342302lfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 01:18:32 -0700 (PDT)
Received: from [192.168.11.166] (dynamic-31-25-120-010.ftth.glattnet.ch. [31.25.120.10])
        by smtp.gmail.com with ESMTPSA id by7sm27668016wjc.18.2016.04.04.01.18.30
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Mon, 04 Apr 2016 01:18:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm experiencing a peculiar problem with PHY communication in the 
current davinci-mdio.c driver.
After upgrading from kernel 3.17 to 4.5 my DT based AM1808 board started 
having issues with the PHY communication.
The MAC is detected, the MDIO is detected, the PHY is detected 
(twice?!?!), however there is no data being sent/received and the after 
issuing "ifdown -a" the MDIO starts spitting out messages that it cannot 
connect to the PHY:

net eth0: could not connect to phy davinci_mdio.0:00
davinci_mdio davinci_mdio.0: resetting idled controller


I'm using a single Micrel KSZ8081 PHY connected via RMII using the 
default PHY address 0x01.
Here is the dmesg excerpt related to mdio:

davinci_mdio davinci_mdio.0: Runtime PM disabled, clock forced on.
davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
davinci_mdio davinci_mdio.0: detected phy mask fffffffc
libphy: davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[0]: device davinci_mdio.0:00, driver 
Micrel KSZ8081 or KSZ8091
davinci_mdio davinci_mdio.0: phy[1]: device davinci_mdio.0:01, driver 
Micrel KSZ8081 or KSZ8091
davinci_mdio davinci_mdio.0: resetting idled controller
Micrel KSZ8081 or KSZ8091 davinci_mdio.0:00: failed to disable NAND tree 
mode
Micrel KSZ8081 or KSZ8091 davinci_mdio.0:00: attached PHY driver [Micrel 
KSZ8081 or KSZ8091] (mii_bus:phy_addr=davinci_mdio.0:00, irq=-1)


After a soft-reboot the MDIO uses a different PHY mask fffffffd, detects 
correctly only one PHY at address 1 (this is the default address) and 
the networking works:

davinci_mdio davinci_mdio.0: Runtime PM disabled, clock forced on.
davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
davinci_mdio davinci_mdio.0: detected phy mask fffffffd
libphy: davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[1]: device davinci_mdio.0:01, driver 
Micrel KSZ8081 or KSZ8091
davinci_mdio davinci_mdio.0: resetting idled controller
Micrel KSZ8081 or KSZ8091 davinci_mdio.0:01: attached PHY driver [Micrel 
KSZ8081 or KSZ8091] (mii_bus:phy_addr=davinci_mdio.0:01, irq=-1)


I'm wondering what the problem is and why the PHY mask is different 
after power-up and after a soft reboot.
Also it's not clear to me why this set-up worked with kernel 3.17 even 
if it was detecting the PHY twice exactly the same way.
How does the mask relate to the PHY address and how is it calculated?

Thanks
Petr
