From: chenweilong <chenweilong@huawei.com>
Subject: BUG: Didn't modify route table when change interface's second address
Date: Tue, 17 Dec 2013 11:06:50 +0800
Message-ID: <52AFBFCA.4060401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:52412 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3LQDHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 22:07:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The bug came out by this:
1.ifconfig eth0:1 192.168.0.1
2.route add default gw 192.168.0.1
3.ifconfig eth0:1 172.168.0.1
4.route table is:
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         192.168.0.1     0.0.0.0         UG    0      0        0 eth0
default         128.5.130.254   0.0.0.0         UG    0      0        0 eth0
loopback        *               255.0.0.0       U     0      0        0 lo
128.5.130.0     *               255.255.255.0   U     0      0        0 eth0
link-local      *               255.255.0.0     U     0      0        0 eth0
172.168.0.0     *               255.255.0.0     U     0      0        0 eth0

Notice that,192.168.0.1 should be deleted because eth0:1's IP had been changed.

This bug seems to be long time exist.I test on kernel version 2.6.32 and 3.0.13,they both have the question.

https://bugzilla.kernel.org/show_bug.cgi?id=67171
