From: Phil Reid <preid@electromag.com.au>
Subject: rfi: stmmac: creating an of mdio bus for attached dsa
Date: Fri, 18 Sep 2015 15:26:36 +0800
Message-ID: <55FBBCAC.1080904@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy2.45ru.net.au ([203.30.46.146]:33246 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752654AbbIRHdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 03:33:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G'day All,

Prior to submitting a patch I'd just like to get an idea on what the 
correct way is to create and register an mdio bus for use by the marvell 
dsa driver.
On our system the cpu ethernet port is connected directly to a switch 
with a fixed link (1Gbit).
So the driver needs to create and persist the mdio bus for the dsa 
driver using of_mdiobus_register.
The trunk stmmac driver currently doesn't create the mdio bus if a fixed 
link is found.
stmmac_probe_config_dt does hte following check.
     if (plat->phy_node || plat->phy_bus_name)
         plat->mdio_bus_data = NULL;
phy_node is set because a fixed-link is found above and setting 
mdio_bus_data to null skips mdio bus creation.
removing the phy_node check gets things working.

I've also modified stmmac_mdio_register to use of_mdiobus_register and 
setup the dt to probe for a phy (that doesn't really exist, the switch 
is on the mdio).
This cause a fair bit of log spamming but does seem to work as the 
switch is detected.
eg: eth0: PHY ID 00000000 at 27 IRQ POLL (stmmac-0:1b)
Currently if no phy is found the mdio bus gets de registered so this 
seems to be required.

In summary what is the correct way to make sure the mdio bus stays 
registered when a fixed-link is in use?
Am I configuring the link to the switch incorrectly?


Phil
