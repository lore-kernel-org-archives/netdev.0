From: Michael Tokarev <mjt@tls.msk.ru>
Subject: [heads-up] bridge in kernel 3.0~ and dhcp from kvm guest on tap device
Date: Thu, 07 Jul 2011 13:44:57 +0400
Message-ID: <4E158019.9040604@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, KVM list <kvm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:51288 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123Ab1GGJo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 05:44:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The combination in $subject apparently stopped working --
I'm running 3.0-rc6 kernel on host where it doesn't work.

The setup is -- a bridge, br0, to which host eth0 and guest
tap devices are connected.

When KVM guest boots, it tries to send DHCP requests to
its ethernet device (it does not matter which device it
uses - be it virtio or e1000 or rtl8139, all work the
same).  These requests appears (can be seen) on the tap
device, but they never propagate to bridge.

Example of a packet as seen on the tap device from a
windows7 guest:

# tcpdump -npvi tap-kvm port bootpc
tcpdump: WARNING: tap-kvm: no IPv4 address assigned
tcpdump: listening on tap-kvm, link-type EN10MB (Ethernet), capture size 65535 bytes
13:38:21.435032 IP (tos 0x0, ttl 128, id 109, offset 0, flags [none], proto UDP (17), length 328)
    0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 52:54:00:12:34:56, length 300, xid 0xdc8f28b1, secs 7168, Flags [Broadcast]
	  Client-Ethernet-Address 52:54:00:12:34:56
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: Discover
	    Client-ID Option 61, length 7: ether 52:54:00:12:34:56
	    Hostname Option 12, length 7: "mjt-006"
	    Vendor-Class Option 60, length 8: "MSFT 5.0"
	    Parameter-Request Option 55, length 12:
	      Subnet-Mask, Domain-Name, Default-Gateway, Domain-Name-Server
	      Netbios-Name-Server, Netbios-Node, Netbios-Scope, Router-Discovery
	      Static-Route, Classless-Static-Route, Classless-Static-Route-Microsoft, Vendor-Option

Exactly the same thing happens with 4 different DHCP
clients: it's ipxe boot rom (network booting of a KVM
guest), win7 built-in DHCP client, udhcpc and dhcp3.

All other traffic - so far anyway - works correcty.

Right now I don't have time to debug the issue, will try
to bisect later.  But if anyone have pointers or thoughts,
please shot away ;)

Thanks!

/mjt
