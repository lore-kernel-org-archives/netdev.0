From: Steven Barth <cyrus@openwrt.org>
Subject: ipv6: throw route behaves like unreachable route (IPv4 works)
Date: Fri, 13 Mar 2015 10:23:40 +0100
Message-ID: <5502AC9C.7070101@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.core-networks.de ([82.96.72.7]:49658 "EHLO
	mail.core-networks.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbbCMJuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:50:17 -0400
Received: from localhost ([127.0.0.1])
	by mail.core-networks.de id 1YWLoh-0004jB-6N
	with ESMTPSA (TLSv1.2:DHE-RSA-AES128-SHA:128)
	for netdev@vger.kernel.org; Fri, 13 Mar 2015 10:23:39 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I have the following minimal set of policy rules and routes.

ip -6 rule add lookup 33333 priority 33333
ip -6 route add throw 2001:db8::1
ip -6 route add 2001:db8::1 via fe80::1 dev wlan0 table 33333
ip route get 2001:db8::1

Now I would expect the call to ip route get (and with that also actual 
routing) to route these packages via
fe80::1 on wlan0 however what route get actually returns is:

throw 2001:db8::1 from :: dev lo  src [...]  metric 1024  error -11


Doing the exact same thing with IPv4 in contrast works as expected.

ip rule add lookup 33333 priority 33333
ip route add throw 1.2.3.4
ip route add 1.2.3.4 via 192.168.0.1 dev wlan0 table 33333
ip route get 1.2.3.4

returns:
1.2.3.4 via 192.168.0.1 dev wlan0  src [...]


It seems to me that the throw route in IPv6 does not actually cause 
further evaluation of policy rules and instead behaves like an 
unreachable route.

Do you have any ideas on how to address this or did I miss anything 
important?

My current kernel is 3.19.1 but older kernels (e.g. 3.14) seem to have 
the same issue.



Thanks,

Steven
