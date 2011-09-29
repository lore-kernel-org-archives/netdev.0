From: William Thompson <wt@electro-mechanical.com>
Subject: Network problem with bridge and virtualbox
Date: Thu, 29 Sep 2011 08:49:41 -0400
Message-ID: <20110929124941.GA16567@electro-mechanical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.electro-mechanical.com ([216.184.71.30]:56805 "EHLO
	mail.electro-mechanical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754739Ab1I2NGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 09:06:21 -0400
Received: from root by mail.electro-mechanical.com with local (Exim 4.69 #1 (Debian))
	id 1R9G3Z-0005n2-S2
	for netdev@vger.kernel.org; Thu, 29 Sep 2011 08:49:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please keep me in the CC as I am not subscribed.

I'm using a 64-bit kernel 3.0.0 and virtualbox 4.1.2.

My problem is that I cannot ping the host from a virtual machine.

My bridge is configured as follows:
# brctl addbr br0
# brctl setfd br0 0
# brctl stp br0 off
# ifconfig br0 10.2.3.1 netmask 255.255.255.0

In the virtual machine, it is set to use br0 as it's interface (bridge mode)
and it's IP is 10.2.3.10.

The host gets packets from the vm, but the vm does not receive packets back. 

I have this same setup working on a 32-bit kernel 2.6.38.6 on another
machine with virtualbox 4.0.4.

I had a thought that the bridge on the host wasn't responding due to having
no ports configured so I added one of my spare ethernet cards to it as
follows:
# brctl addif br0 eth1
# ifconfig eth1 up

The card was plugged into a switch.  After doing this, the vm still could not
talk to the host.  I added a physical machine to the switch that eth1 was
connected to and configured it to 10.2.3.2.  I was able to ping 10.2.3.2 but
not 10.2.3.1
