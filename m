From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv5 0/3 (+3)] Interface group patches
Date: Fri, 26 Oct 2007 14:30:29 +0200
Message-ID: <11934018353825-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50173 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027AbXJZMak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 08:30:40 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id E871FC1195
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 14:30:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the 5th version of our interface group patches.

The first patch is a fix in the rtnl socket interface.

An u_int32_t member was added to net devices indicating the interface
group number of the device which can be get/set via netlink.

The xt_ifgroup netfilter match is for checking this value with an
optional mask.

Other patches are for userpace programs:
 * iptables
 
 * iproute2. Because kernel 2.6.24-rc1 introduced a new enum value,
   IFLA_NET_NS_PID, and it wasn't in the iproute2 code, the first
   patch simply adds this value. The second patch adds support of
   interface group.

Usage:
 ip link set eth0 group 4    # set
 ip link set eth0 group 0    # unset
 iptables -A INPUT -m ifgroup --ifgroup-in 4/0xf -j ACCEPT
 iptables -A FORWARD -m ifgroup --ifgroup-in 4  ! --ifgroup-out 5 -j DROP

Patches:
 [1/3] rtnetlink: setlink changes atomic with single notification
 [2/3] Interface group: core (netlink) part
 [3/3] Netfilter Interface group match
 [iptables] Interface group match
 [iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
 [iproute 2/2] Interface group as new ip link option

--
Laszlo Attila Toth
