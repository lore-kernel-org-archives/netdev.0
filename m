From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Netlink, route monitoring, =?UTF-8?Q?RTM=5FDELROUTE=20not=20issue?=
 =?UTF-8?Q?d=20for=20ppp=20peer=20address=2E=20Bug=20or=20feature=3F?=
Date: Fri, 13 Apr 2012 15:10:34 +0300
Message-ID: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:46028 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab2DMMKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 08:10:41 -0400
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id C4CE02EC056
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 15:10:34 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am trying to implement my own routing daemon, and using 
RTMGRP_IPV4_ROUTE to monitor routes.
I notice, that on PPPoE, when interface disappearing, RTM_DELROUTE will 
be sent to listener only for local address, but nothing about peer 
address attached to this interface.

CBSS_PPPoE ~ # ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol
           inet addr:172.16.146.1  P-t-P:172.16.146.10  
Mask:255.255.255.255
           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1200  Metric:1
           RX packets:40439 errors:0 dropped:0 overruns:0 frame:0
           TX packets:63211 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:3
           RX bytes:3584507 (3.4 MiB)  TX bytes:47180929 (44.9 MiB)

CBSS_PPPoE ~ # pppkill tek234@visp.net.lb  (this is killing pppd 
process for ppp0 interface)

ip monitor route will show only RTM_DELROUTE for RTN_LOCAL, but nothing 
about RTN_UNICAST for 172.16.146.10.
"Deleted local 172.16.146.1 dev ppp0  table local  proto kernel  scope 
host  src 172.16.146.1"
My program also receive same.

Is it a bug, that no RTM_DELROUTE issued for peer ip address? Or should 
i monitor also RTMGRP_IPV4_IFADDR for link disappearance?

Thanks for help!
