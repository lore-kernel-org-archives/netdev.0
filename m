From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 15:00:26 +0000
Message-ID: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34227 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbJ2PA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:00:29 -0400
Received: by padhk11 with SMTP id hk11so43310355pad.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 08:00:29 -0700 (PDT)
Received: from ?IPv6:2a06:98c0:1000:1200:5c8f:2e3:21d0:5600? ([2a06:98c0:1000:1200:5c8f:2e3:21d0:5600])
        by smtp.gmail.com with ESMTPSA id bz1sm2893888pab.20.2015.10.29.08.00.27
        for <netdev@vger.kernel.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 29 Oct 2015 08:00:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
testing Any-IP on my machine, I noticed that it's not working with IPv6
addresses.
Tests are performed on a 4.1 kernel.

Steps to reproduce the bug:

1- make sure Any-IP is working with IPv4 addresses:

# ip -4 route add local 4.4.4.0/24 dev eth0

with this command every packets with an IP in the subnet 4.4.4.0/24 will
be delivered to the eth0 interface.
We can test this:

$ ping 4.4.4.1 -c 1 | grep received
1 packets transmitted, 1 received, 0% packet loss, time 0ms
$ ping 4.4.4.50 -c 1 | grep received
1 packets transmitted, 1 received, 0% packet loss, time 0ms
$ ping 4.4.4.200 -c 1 | grep received
1 packets transmitted, 1 received, 0% packet loss, time 0ms

2- note that it's not actually working with IPv6 addresses:

# ip -6 route add local abcd:abcd:abcd:abcd::/64 dev eth0

$ ping6 -c 1 abcd:abcd:abcd:abcd::1 | grep received
1 packets transmitted, 0 received, 100% packet loss, time 0ms
$ ping6 -c 1 abcd:abcd:abcd:abcd::50 | grep received
1 packets transmitted, 0 received, 100% packet loss, time 0ms
$ ping6 -c 1 abcd:abcd:abcd:abcd::100 | grep received
1 packets transmitted, 0 received, 100% packet loss, time 0ms

Since the kernel should support Any-IP with IPv6 addresses (the patch
was submitted/accepted years ago [1]) I suspect this is a bug.

Even trying with the commands suggested by the patch [1]:
# ip -6 rule  add from all iif eth0 lookup 200
# ip -6 route add local default dev lo table 200

I was not able to get it working.


Thank you.

[1] http://www.spinics.net/lists/netdev/msg141994.html
