From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 13:03:18 +0200
Message-ID: <BAY103-F2CBF2C86BB9EF11201CBEB2580@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s3.bay0.hotmail.com ([65.54.246.139]:43304 "EHLO
	bay0-omc2-s3.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751144AbWG0LDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 07:03:23 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everybody.
I'm running linux 2.6.16.27 on my firewall/ipsec gateway
with openswan 2.4.5
This is my firewall/network schema:

   |
   | /--eth0 (connected to ISP router)
   |/
+--+--+
|     |
|     +--eth1 (DMZ)
|     |
+--+--+
   |\
   | \--eth2 (internal network 172.16.0.0/23)
   |
  +-+
  | | <--router to reach 10.180.0.0/16 network
  +-+    172.16.1.253

I have also configured an IPsec tunnel to delivery traffic
from 172.16.0.0/23 network to 10.0.0.0/8 network.
This is the relevant routing table portion on the linux
box:

172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
10.180.0.0/16 via 172.16.1.253 dev eth2
10.0.0.0/8 via pub_ip dev eth0
127.0.0.0/8 dev lo  scope link

I have noticed that packets for 10.180.0.0/16 network
are eaten by the ipsec tunnel because the policy allow
them. Is there a way to deliver packets for 10.180.0.0
network to the 172.16.1.253 router (because the route
to 10.180.0.0 is more specific than 10.0.0.0/8)?

TIA


