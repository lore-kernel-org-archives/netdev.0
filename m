From: Florian Reitmeir <florian@reitmeir.org>
Subject: VLAN & ARP requests
Date: Wed, 12 Apr 2006 18:32:43 +0200
Message-ID: <20060412163242.GU25152@squat.noreply.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from opium.multi24.com ([213.239.202.166]:17637 "EHLO
	opium.multi24.com") by vger.kernel.org with ESMTP id S932127AbWDLQco
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 12:32:44 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I don't if this a bug, and i tried to get some documentation about the
behavier but failed, so here is my question..

(i tested this with 2.6.14 & 2.6.16.1)
I have two network interfaces,

lan = a1000 ethernet
wlan = ipw2200 wireless

then I give them the same network address/subnet

ifconfig lan 10.200.20.20 netmask 255.255.255.0
ifconfig wlan 10.200.20.20 netmask 255.255.255.0

(there is no promisc mode or any other non default config)

now I try to ping an address which is not on my network for e.g.
ping 10.200.20.30
and use tcpdump -pni lan|wlan to look at the arp requests. The kernel asking
arp on the two interfaces. Everything is OK.
(also there are two routes for the networks, one for each interface)


now I add VLANs, 
vconfig add lan 12
vconfig add lan 20

and give them also the same ip address:
ifconfig lan.12 10.200.20.20 netmask 255.255.255.0
ifconfig lan.20 10.200.20.20 netmask 255.255.255.0

and try to ping.. 

and now .. there are no arp requests for those two interfaces. sometime when
i disable for example the wlan interface, there is an arp request on _one_
of the vlan interfaces (that one which has the first route), but never on
all.

On the lan interface are always arp requests, even if i try to change the
macaddress of the vlan interfaces, or change the ip to an other subnet.


In my opinion the kernel should also send arp request on the vlan interfaces,
so they behave identical like the physical ones.

Any clues to that problem? (btw. I now that this is'nt a common configuration)

-- 
Florian Reitmeir
