From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/2] gre: allow to switch netns during encap/decap
Date: Tue, 22 Apr 2014 10:15:22 +0200
Message-ID: <1398154524-5928-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, mzero@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:50001 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbaDVIPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 04:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to add x-netns support for the module ip_gre and
ip6_gre, ie the encapsulation addresses and the network device are not owned by
the same namespace.

Example to configure an ipv4 gre tunnel:

modprobe ip_gre
ip netns add netns1
ip netns exec netns1 ip link set lo up
ip link add gre1 type gre remote 10.16.0.121 local 10.16.0.249 ikey 10 okey 10 csum
ip link set gre1 netns netns1
ip netns exec netns1 ip link set gre1 up
ip netns exec netns1 ip addr add dev gre1 192.168.0.249 remote 192.168.0.121

 net/ipv4/ip_gre.c  |  6 +++---
 net/ipv6/ip6_gre.c | 52 ++++++++++++++++++++++++++++++++--------------------
 2 files changed, 35 insertions(+), 23 deletions(-)

Comments are welcome.

Regards,
Nicolas
