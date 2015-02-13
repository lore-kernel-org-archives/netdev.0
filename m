From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Question on Bonding driver
Date: Fri, 13 Feb 2015 12:11:50 -0500
Message-ID: <54DE3056.6020606@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47324 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455AbbBMRLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 12:11:45 -0500
Received: from dlelxv90.itg.ti.com ([172.17.2.17])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id t1DHBivr024208
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 11:11:44 -0600
Received: from DLEE71.ent.ti.com (dlee71.ent.ti.com [157.170.170.114])
	by dlelxv90.itg.ti.com (8.14.3/8.13.8) with ESMTP id t1DHBhn9016598
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 11:11:43 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am working to enable bonding driver on my hardware and trying to 
understand this.

I am using the alb mode. I create a bond interface with 2 ethernet 
interfaces. First one is the basic question about net driver itself and 
second is about bonding.

1. Each ethernet interface has a MAC address. The hardware has MAC 
filter and the driver fills the net_device's dev_addr with its MAC 
address before calling register_netdev() API. When the net core calls 
ndo_start(), is the low level driver responsible for setting up its MAC 
address in the MAC filter of the hardware or low level driver will be 
told to do so by upper layer. Or is it required to set it up as part of 
ndo_set_rx_mode() or ndo_set_mac_address()?

2. In the case of bonding, the bond interface MAC address is copied from 
the active slave's MAC address. Also it updates the dev_addr in the 
netdev struct of each of the slave with its own MAC address. So I 
assume, the device/NIC now needs to accept packets to its original MAC 
address as well the bond's MAC address. This is especially more 
important for the slave's that are not active slave as it can be target 
of packets from Peers as part of rlb. So for the slave that is not 
active slave, MAC filter needs to include its original hw address as 
well unless the slave is put to promiscuous mode. So I am trying to 
figure out how this is expected to work? All slaves put to promiscuous 
mode or MAC filter updated by slave driver to include MAC addresses it 
is expected to filter on (bond MAC address and its own MAC address)

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
