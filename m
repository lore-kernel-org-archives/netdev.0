From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: usbnet: doc updates
Date: Mon, 06 Sep 2010 12:57:48 -0700 (PDT)
Message-ID: <20100906.125748.189711276.davem@davemloft.net>
References: <20100905.215759.193704169.davem@davemloft.net>
	<537964.70523.qm@web180307.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753051Ab0IFT5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 15:57:30 -0400
In-Reply-To: <537964.70523.qm@web180307.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Mon, 6 Sep 2010 11:28:48 -0700 (PDT)

> You wouldn't know of a Linux distro that comes
> with a "this box will be a NAT firewall" setup
> option?  Ubuntu only has that aftermarket AFAICT.

Just do a bare debian install and put something like the file below in
your /etc/network/interfaces, it's what I use.

eth0 is outgoing, eth1 is internal network.  Change eth0 to a dhcp
config if that is what you use.

I also use dnsmasq as the dhcp server for the internal network.

IP addresses variable'ized to protect the innocent :-)

--------------------
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
      address $(INTERNET_IP)
      netmask $(INTERNET_NETMASK)
      network $(INTERNET_NETWORK)
      broadcast $(INTERNET_BROADCAST)
      gateway $(INTERNET_GATEWAY)
      dns-nameservers $(INTERNET_DNS_1) $(INTERNET_DNS_2)

allow-hotplug eth1
iface eth1 inet static
      address 11.0.0.1
      netmask 255.0.0.0
      network 11.0.0.0
      broadcast 11.255.255.255
      up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
