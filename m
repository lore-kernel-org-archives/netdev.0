From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: DHCP response received after 500mS not handled while having multiple
 Ethernet interfaces
Date: Wed, 28 Nov 2012 01:28:40 +0530
Message-ID: <50B51B70.5050804@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53299 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab2K0T7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 14:59:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

While testing AM335X which has Dual EMAC feature, I came across an issue.

Setup:
     Board:  AM335X-EVMSK with Dual EMAC implementation with eth0 connected
             and eth1 not connected to switch.
     Router: Trendnet Wireless router TEW-652BRP

Issue:
    While booting with multiple Ethernet interface, kernel logs as
    "DHCP/BOOTP: Ignoring delayed packet" and ignores the DHCP response 
packet.

Analysis:
The router is giving a DHCP response only after 500mS which I confirmed by
capturing Ethernet packets
While looking at net/ipv4/ipconfig.c, it seems that waiting period of DHCP
response with multiple interface is 500mS, if we get a response from the
server after 500mS, it is ignored as ic_dev_xid will hold the next interface
xid which is updated while sending DHCP request after timeout on the next
interface.

Is this 500mS waiting for response period is per protocol?

In my view even if we get a response after 500mS and DHCP request has moved
to next interface we need to handle the response.
Can someone comment on this approach is right or is there some other way to
handle the issue.

Regards
Mugunthan V N
