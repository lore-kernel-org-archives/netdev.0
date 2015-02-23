From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH net-next v3 0/2] Multicast group join/leave at ip level
Date: Sun, 22 Feb 2015 22:26:52 -0800
Message-ID: <1424672814-2998-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: eric.dumazet@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:46624 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbbBWGnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 01:43:11 -0500
Received: by pdjy10 with SMTP id y10so23142988pdj.13
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 22:43:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series enables configuring multicast group join/leave at ip level
by extending the "ip address" command. 

It adds a new control socket mc_autojoin_sock and ifa_flag IFA_F_MCAUTOJOIN
to invoke the corresponding igmp group join/leave api.

Since the igmp group join/leave api takes the rtnl_lock the code had to
be refactored by adding a shim layer prefixed by __ that can be invoked
by code that already has the rtnl_lock. This way we avoid proliferation of
work queues.

The first patch in this series does the refactoring for igmp v6. 
Its based on igmp v4 changes that were added by Eric Dumazet.

The second patch in this series does the group join/leave based on the
setting of the IFA_F_MCAUTOJOIN flag.

v3:
- addressed comments from David Miller.
 - fixed indentation and local variable order.
v2:
- addressed comments from Eric Dumazet.
 - removed workqueue and call __ip_mc_{join|leave}_group or
   __ipv6_sock_mc_{join|drop}

Madhu Challa (2):
  igmp v6: add __ipv6_sock_mc_join and __ipv6_sock_mc_drop
  multicast: Extend ip address command to enable multicast group
    join/leave on IP level.

 include/net/ipv6.h           |  8 ++++++
 include/net/netns/ipv4.h     |  1 +
 include/net/netns/ipv6.h     |  1 +
 include/uapi/linux/if_addr.h |  1 +
 net/ipv4/devinet.c           | 36 ++++++++++++++++++++++++++
 net/ipv4/igmp.c              | 17 ++++++++++++
 net/ipv6/addrconf.c          | 39 +++++++++++++++++++++++++---
 net/ipv6/mcast.c             | 61 ++++++++++++++++++++++++++++++++++----------
 8 files changed, 148 insertions(+), 16 deletions(-)

-- 
1.9.1
