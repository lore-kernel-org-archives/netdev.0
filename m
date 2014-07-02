From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 0/5] netns: allow to identify peer netns
Date: Wed,  2 Jul 2014 13:59:01 +0200
Message-ID: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
References: <537327F1.4060603@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53373 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaGBMIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:08:42 -0400
In-Reply-To: <537327F1.4060603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to be able to multicast netlink messages with an
attribute that identify a peer netns.
This is needed by the userland to interpret some informations contained in
netlink messages (like IFLA_LINK value, but also some other attributes in case
of x-netns netdevice (see also
http://thread.gmane.org/gmane.linux.network/315933/focus=316064)).

Each network namespaces allocates its own ids for other netns (including
itself). The user can retrieve these ids via a new netlink messages, but only
if he has a FD which points to this netns. Dump is not implemented so that a
user cannot get the whole netns list.

The goal of this RFC is mainly to validate the principle, ie patch 1/5 and 2/5.
Patch 3/5 and 4/5 shows an example of how to use these ids in rtnetlink
messages. And patch 5/5 shows that the netlink messages can be symetric between
a GET and a SET.

iproute2 patches are available, I can send them on demand.

 include/net/ip_tunnels.h     |   1 +
 include/net/net_namespace.h  |   6 ++
 include/net/rtnetlink.h      |   2 +
 include/uapi/linux/Kbuild    |   1 +
 include/uapi/linux/if_link.h |   1 +
 include/uapi/linux/netns.h   |  27 ++++++++
 net/core/net_namespace.c     | 143 +++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c         |  39 +++++++++++-
 net/ipv4/ip_gre.c            |   2 +
 net/ipv4/ip_tunnel.c         |   8 +++
 net/ipv4/ip_vti.c            |   1 +
 net/ipv4/ipip.c              |   1 +
 net/ipv6/sit.c               |   1 +
 net/netlink/genetlink.c      |   4 ++
 14 files changed, 234 insertions(+), 3 deletions(-)

Comments are welcome.

Regards,
Nicolas
