From: Wolfgang Nothdurft <netdev@linux-dude.de>
Subject: Forcing the output interface using ip6_route_output doesn't work
Date: Fri, 25 Sep 2015 15:56:55 +0200
Message-ID: <560552A7.40305@linux-dude.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-dude.de ([213.179.141.24]:43248 "EHLO
	mail.linux-dude.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216AbbIYOQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:16:11 -0400
Received: from server.linux-dude.de (ppp-46-244-160-117.dynamic.mnet-online.de [46.244.160.117])
	(authenticated bits=0)
	by mail.linux-dude.de (8.14.9/8.14.9) with ESMTP id t8PDv3R4029806
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 15:57:03 +0200
Received: from wolfi.linogate.intern (support.linogate.de [213.179.141.14] (may be forged))
	by server.linux-dude.de (8.14.9/8.14.9) with ESMTP id t8PDuu59004841
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 15:56:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that the ip6_route_output(net, sk, fl6) kernel function ignores 
the fl6.flowi6_oif parameter for the routing decision.

Is this intended?
Should it possible to force the output device for ipv6 routing just as 
for ipv4?

Here the example shown with the ip command:

With ipv4, I'm able to get the default route when using oif (force the 
output interface).

# ip r

default via 192.168.0.1 dev enp3s0 proto static
192.0.2.0/24 dev enp2s0 proto kernel scope link src 192.0.2.163
192.168.0.0/24 dev enp3s0 proto kernel scope link src 192.168.0.163

# ip r get 192.0.2.10
192.0.2.10 dev enp2s0  src 192.0.2.163
     cache

# ip r get 192.0.2.10 oif enp3s0
192.0.2.10 via 192.168.0.1 dev enp3s0  src 192.168.0.163
     cache

With ipv6, ip -6 route get always returns the specific route.

# ip -6 r
2001:db8:e2::1 dev enp2s0  proto kernel  metric 256
2001:db8:e2::/64 dev enp2s0  metric 1024
2001:db8:e3::1 dev enp3s0  proto kernel  metric 256
2001:db8:e3::/64 dev enp3s0  metric 1024
fe80::/64 dev enp3s0  proto kernel  metric 256
default via 2001:db8:e3::255 dev enp3s0  metric 1024

ip -6 r get 2001:db8:e2::100
2001:db8:e2::100 from :: dev enp2s0  src 2001:db8:e3::1  metric 0
     cache

# ip -6 r get 2001:db8:e2::100 oif enp3s0
2001:db8:e2::100 from :: dev enp2s0  src 2001:db8:e3::1  metric 0
     cache

The detailed problem is described here, because I got the problem 
initially when trying a ipsec Host-2-Host connection with libreswan/klips.

https://bugs.libreswan.org/show_bug.cgi?id=237

Thanks
Wolfgang
