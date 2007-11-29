From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 0/5 + 3] Interface group patches
Date: Thu, 29 Nov 2007 17:11:41 +0100
Message-ID: <11963527094077-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50905 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917AbXK2QLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:11:53 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 53B57C1481
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:11:51 +0100 (CET)
Message-Id: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the 7th version of our interface group patches.

The interface group value can be used to manage different interfaces
at the same time such as in netfilter/iptables. 

As earlier discussed, it can be used for advanced routing, tc command
and so on [1].

An u_int32_t member was added to net devices indicating the interface
group number of the device which can be get/set via netlink.

The xt_ifgroup netfilter match is for checking this value with an
optional mask.

Changes:
  -  The first patch of the previous version splitted into 2 separate
  patches.

  - The ip command now let values larger than 0xff be set, octal, decimal
  and hexadecimal values are valid and in the range of 0x00-0xff any
  name can be used (from /etc/iproute2/rt_ifgroup).

  - added sysfs support to read/write the ifgroup value


Other patches are for userpace programs:
 * iptables

 * iproute2. Because kernel 2.6.24-rc1 introduced a new enum value,
   IFLA_NET_NS_PID, and it wasn't in the iproute2 code, the first
   patch simply adds this value. The second patch adds support of
   interface group.

Usage:
 ip link set eth0 group 684    # set
 ip link set eth0 group 0      # unset
 iptables -A INPUT -m ifgroup --ifgroup-in 4/0xf -j ACCEPT
 iptables -A FORWARD -m ifgroup --ifgroup-in 4  ! --ifgroup-out 5 -j DROP

Patches:
 [1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
 [2/5] rtnetlink: send a single notification on device state changes
 [3/5] Interface group: core (netlink) part
 [4/5] Ifgroup read/write support in sysfs
 [5/5] Netfilter Interface group match
 [iptables]Interface group match
 [iproute2 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
 [iproute2 2/2] Interface group as new ip link option



Rererences:
 [1] http://marc.info/?l=linux-netdev&m=119556459514598&w=2
--
Laszlo Attila Toth
