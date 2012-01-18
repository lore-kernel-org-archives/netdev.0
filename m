From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: route problem
Date: Wed, 18 Jan 2012 14:47:50 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:44092 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756610Ab2ARJRx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 04:17:53 -0500
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id q0I9HpZx029204
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 09:17:51 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have added a route for an external ip via a gateway which is available
on the same machine.
I want to capture the packets going to this external IP using PF_PACKET
socket.

#route 
Destination     Gateway         Genmask         Flags Metric Ref    Use
Iface
192.168.101.0   *               255.255.255.0   U     0      0        0
eth1
172.16.60.0     192.168.101.10  255.255.255.0   UG    0      0        0
eth1

So, when a packet is sent to 172.16.60.*, kernel should send arp request
for this gw IP 192.168.101.10. As gw IP is locally reachable, 
It should send its mac address in arp-response and kernel should send
the packet via that interface.

But what I am seeing is that instead of asking the gateway IP, kernel
sends a arp request for destingation ip(172.16.60.*)

#tcpdump -I eth1
04:12:45.334966 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:46.334839 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:48.334584 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:49.334457 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:50.335329 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:52.335075 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:53.334947 arp who-has 172.16.60.2 tell 192.168.101.20
04:12:54.334821 arp who-has 172.16.60.2 tell 192.168.101.20


Is my understanding correct?

Regards,
Prashant
