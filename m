From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 20:31:51 +0100
Message-ID: <20150310193151.GE10838@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, jogo@openwrt.org,
	f.fainelli@gmail.com
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57084 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024AbbCJTfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 15:35:12 -0400
Content-Disposition: inline
In-Reply-To: <20150310190129.GB5636@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The third point would allow to perform operations currently limited to switch
> ports. Typically, "ethtool -S eth0" could return the corresponding port's MIB
> statistics in addition to the eth0 statistics.

Hi Mathieu

This already works with DSA. I have a WRT1900AC which has a 7 port
switch. With DSA i have:

# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 532
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 532
    link/ether 52:33:3a:a7:c1:8a brd ff:ff:ff:ff:ff:ff
4: lan4@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
5: lan3@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
6: lan2@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
7: lan1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
8: internet@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff

internet would be your WAN port in your diagram. I just named it the
same as the label on the case.

I can get MIB statistics in the normal way for the DSA ports, e.g:

root@wrt1900ac:~# ethtool -S lan1
NIC statistics:
     tx_packets: 153009
     tx_bytes: 13307317
     rx_packets: 161136
     rx_bytes: 21840683
...

	Andrew
