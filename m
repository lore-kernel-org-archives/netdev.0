From: =?ISO-8859-1?Q?Ortwin_Gl=FCck?= <odi@odi.ch>
Subject: xfrm: is pmtu broken with ESP tunneling?
Date: Mon, 10 Feb 2014 09:41:54 +0100
Message-ID: <52F890D2.2060109@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fep27.mx.upcmail.net ([62.179.121.47]:47607 "EHLO
	fep27.mx.upcmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaBJI5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 03:57:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using Openswan to configure an IPSec VPN (using the xfrm/netkey 
backend). Large HTTP POST requests from the client seem to get stuck, 
because the outgoing packets are 1530 bytes (before being wrapped into 
ESP packets). The problem goes away by setting sysctl 
net.ipv4.ip_no_pmtu_disc=1.

May have something to do with it:
The tunneled network is 10.6.6.6/32 and I am SNAT'ing some destinations 
to that IP, so they get routed through the tunnel. Any other networks 
are not to go through the tunnel.

iptables -t nat -A POSTROUTING -d "${R}" -j SNAT --to-source 10.6.6.6

It seems quite clear to me that xfrm is doing something wrong here.

Ortwin
