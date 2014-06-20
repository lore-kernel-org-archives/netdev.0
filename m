From: =?UTF-8?Q?=22Conch=C3=BAr_Navid=22?= <conchur@web.de>
Subject: IP-Packets over wrong Ethernet device
Date: Fri, 20 Jun 2014 10:05:45 +0200
Message-ID: <trinity-115b0f38-53ca-4333-9f3d-0cca5ea770d9-1403251544932@3capp-webde-bs53>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:61067 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933971AbaFTIFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 04:05:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a setup with two links between two devices. One link is used only for management and the second on is a lossy link which is used to send test data. The management link is in the network 192.168.1.x/24 and the second link (lossy) is in 192.168.200.x/24.

Now is see from time to time that data for the network 192.168.200.x/24 is so lossy that it is sent over the link which actually only should handle the data for 192.168.1.x/24. This behavior ruins my test results and I am unsure why it actually happens

Forwarding is not enabled

$ sysctl -a|grep forw
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.all.mc_forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv4.conf.default.mc_forwarding = 0
net.ipv4.conf.eth1.forwarding = 0
net.ipv4.conf.eth1.mc_forwarding = 0
net.ipv4.conf.eth2.forwarding = 0
net.ipv4.conf.eth2.mc_forwarding = 0
net.ipv4.conf.eth3.forwarding = 0
net.ipv4.conf.eth3.mc_forwarding = 0
net.ipv4.conf.eth4.forwarding = 0
net.ipv4.conf.eth4.mc_forwarding = 0
net.ipv4.conf.eth5.forwarding = 0
net.ipv4.conf.eth5.mc_forwarding = 0
net.ipv4.conf.lo.forwarding = 0
net.ipv4.conf.lo.mc_forwarding = 0
net.ipv4.conf.wlan2.forwarding = 0
net.ipv4.conf.wlan2.mc_forwarding = 0
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.mc_forwarding = 0
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.default.mc_forwarding = 0
net.ipv6.conf.eth1.forwarding = 0
net.ipv6.conf.eth1.mc_forwarding = 0
net.ipv6.conf.eth2.forwarding = 0
net.ipv6.conf.eth2.mc_forwarding = 0
net.ipv6.conf.eth3.forwarding = 0
net.ipv6.conf.eth3.mc_forwarding = 0
net.ipv6.conf.eth4.forwarding = 0
net.ipv6.conf.eth4.mc_forwarding = 0
net.ipv6.conf.eth5.forwarding = 0
net.ipv6.conf.eth5.mc_forwarding = 0
net.ipv6.conf.lo.forwarding = 0
net.ipv6.conf.lo.mc_forwarding = 0
net.ipv6.conf.wlan2.forwarding = 0
net.ipv6.conf.wlan2.mc_forwarding = 0


Does anyone has an idea why this can be happening in Linux?

And I've verified that the data is really going incorrectly through the ethernet device of the 192.168.1.x/24 network (management) by capturing tcpdump data on it. The sender of the data then also has the wrong mac address in the ARP table for some time (for unknown reasons). Instead of the mac address of the 192.168.200.x/24 ethernet device, it has the mac address of the 192.168.200.x/24. It will switch back later to the correct MAC of the 192.168.200.x/24 network and sending works correctly again as expected.

A dump on the management network ethernet interface (192.168.1.x/24) shows me that there was really an ARP request of the sender for 192.168.200.x/24 on this interface which was replied by the receiver on that interface. Is there a way to disable this reply on the "wrong" interface without using ARP-tables?

Thanks
