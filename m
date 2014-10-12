From: Angelo Dureghello <angelo70@gmail.com>
Subject: micrel: ksz8051 badly detected as ksz8031
Date: Sun, 12 Oct 2014 14:55:06 +0200
Message-ID: <543A7A2A.5040700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:51662 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaJLMzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2014 08:55:09 -0400
Received: by mail-wi0-f171.google.com with SMTP id em10so5397871wid.16
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2014 05:55:07 -0700 (PDT)
Received: from [192.168.0.2] (host155-25-dynamic.14-87-r.retail.telecomitalia.it. [87.14.25.155])
        by mx.google.com with ESMTPSA id fx10sm8771061wib.12.2014.10.12.05.55.06
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Oct 2014 05:55:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear,

still having trouble debugging why, moving from kernel 3.5.1 to 3.17 i 
don't have
any phy link. This must be an issue of my platform that have to set 
something
additional from my board.c than as in kernel 3.5.1.

Anyway, my hardware has Micrel KSZ8051, but phy probing seems to get 
erroneously
the id KSZ8031 while older kernel 3.5.1 was getting correctly KSZ8051. 
This is
The first thing that make me think that phy link miss due to a bad setup.

The whole mii / mdio / mdio_bus / phy / dacinvi-emac group of drivers is 
really
complex for me to be debugged. Who reads the PHY ID ? Is the wrong PHY 
ID a sign
that mdio is not working properly ?

Kernel 3.5.1
net eth0: attached PHY driver [Micrel KS8051] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)

Kernel 3.17.0
net eth0: attached PHY driver [Micrel KSZ8031] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)


I see phy leds up (both lights up) until the first "Sending discover..." 
message.

UTC
Time zone set
Starting network...
davinci_mdio davinci_mdio.0: resetting idled controller
ipam390_phy_fixup: applying ipam390_phy_fixup
micrel.c: ksz8021_config_init: val=00000202
micrel.c: ksz8021_config_init: val=00000202
micrel.c: enabling 50MHZ input
micrel.c: enabled 50MHZ input
net eth0: attached PHY driver [Micrel KSZ8031] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)
udhcpc (v1.20.2) started
Sending discover...
davinci_emac.c: emac_adjust_link: entering, phydev->link=0
Sending discover...
Sending discover...
No lease, failing



My system have: ARM AM1808 (OMAP-L138),
- davinci-emac.c
- RMII and MDIO to interface to Micrel KSZ8051
- sourcinf 50MHZ clock from emac RMII

Every help is appreciated.

Regards,
Angelo
