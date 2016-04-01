From: Petr Kulhavy <petr@barix.com>
Subject: davinci-mdio: failing to connect to PHY
Date: Fri, 1 Apr 2016 17:24:13 +0200
Message-ID: <56FE929D.2060104@barix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34573 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbcDAPYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:24:16 -0400
Received: by mail-wm0-f42.google.com with SMTP id p65so30503654wmp.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:24:15 -0700 (PDT)
Received: from [192.168.11.166] (dynamic-31-25-120-010.ftth.glattnet.ch. [31.25.120.10])
        by smtp.gmail.com with ESMTPSA id uq10sm14496528wjc.38.2016.04.01.08.24.13
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Fri, 01 Apr 2016 08:24:14 -0700 (PDT)
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


I'm using a single Micrel KSZ8081 PHY connected via RMII.
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


After soft-rebooting the MDIO uses a different PHY mask fffffffd, 
detects correctly only one PHY at address 1 (this is the default 
address) and the networking works:

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
after power-up.
Also it's not clear to me why this set-up worked with kernel 3.17 even 
if it was detecting the PHY twice exactly the same way.
How does the mask relate to the PHY address and how is it calculated?

Thanks
Petr
