From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: IPv6 SO_BINDTODEVICE and Multiple default routes
Date: Thu, 17 Mar 2011 22:54:03 -0300
Message-ID: <AANLkTi=y2O-f0rZNoVwmFxPrF-fBT0Zdb4eQ3_eD59s8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:45297 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab1CRByD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 21:54:03 -0400
Received: by vxi39 with SMTP id 39so3189956vxi.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 18:54:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have two interfaces (wlan0) and (eth0) up and running on my laptop.
Also I have two v6 default routes and neighbor cache set up, as below:

ip route
default via fe80::21a:70ff:fee6:b155 dev eth0  proto ra  metric 996
mtu 1280 advmss 1220 hoplimit 0
default via fe80::21a:70ff:fee6:b155 dev wlan0  proto ra  metric 999
mtu 1280 advmss 1220 hoplimit 0

ip -6 neigh
fe80::21a:70ff:fee6:b155 dev wlan0 lladdr 00:1a:70:e6:b1:55 router STALE
2001:470:c1fa:1083:: dev wlan0 lladdr 00:1a:70:e6:b1:55 STALE
2001:470:c1fa:1083:: dev eth0 lladdr 00:1a:70:e6:b1:55 STALE
fe80::21a:70ff:fee6:b155 dev eth0 lladdr 00:1a:70:e6:b1:55 router REACHABLE

Im opening 2 UDPv6 sockets, and using SO_BINDTODEVICE so as to bind
each one respectively to "wlan0" and "eth0".

However the communication takes place just over eth0 socket. Over
wlan0 the application gets the message "Network Unreachable". However
if I configure the two default routes with the same metric then the
binding to "wlan0" comes to work nicely.

Debugging the ip6_pol_route function inside the kernel I could figure
out that the default route to "wlan0" is not being considered at all
when the metrics for the two v6 default routes are different from each
other, it's considered if the metrics for the two default routes are
the same, though.

Is this behaviour expected ?

Regards,
Eduardo Panisset.
