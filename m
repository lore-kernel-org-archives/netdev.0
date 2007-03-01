From: Robert Dyck <rob.dyck@telus.net>
Subject: Application on MASQ node can hijack port used by application on gateway
Date: Thu, 1 Mar 2007 13:21:23 -0800
Message-ID: <200703011321.24195.rob.dyck@telus.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jjciarla@raiz.uncu.edu.ar, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defout.telus.net ([199.185.220.240]:65381 "EHLO
	defout.telus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030283AbXCAVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 16:21:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When nodes on the LAN are masqueraded Linux on the gateway will attempt to use 
the same port that an app on the LAN used. This can only be done once after 
which Linux will arbitrarily assign ports.

Using the example of VoIP phones which use a default port of 5060, the first 
phone to register with proxy server will be assigned port 5060 on the gateway 
and the second would be assigned port 1024. Keep-alive packets are used by 
the phones, the proxy or both to maintain the NAT bindings. The proxy makes 
note of the originating port. Incoming packets are routed correctly.

Now consider the case of a application running on the gateway box. It would 
send and listen on port 5060. In this case we would not use keep-alive 
packets. We open port 5060 on the firewall so that we can receive calls from 
the public internet. I have observed that a phone on the LAN can bind to port 
5060 even though the application had grabbed port 5060. The result is that 
packets intended for the application will be routed to the phone on the LAN. 
The phone on the LAN also gets packets intended for it.

This was confirmed by /proc/net/ip_conntrack and also by capturing packets 
with a sniffer. The contents of the packets showed that some of the packets 
were clearly not intended for the phone that received them. The application 
listening on port 5060 received nothing.

Rob Dyck
