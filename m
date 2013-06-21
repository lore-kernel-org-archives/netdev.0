From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] virtual netlink device for packet sockets
Date: Fri, 21 Jun 2013 19:38:05 +0200
Message-ID: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422925Ab3FURiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 13:38:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set allows for a virtual netlink device that can be easily used
without modification by tools like tcpdump, Wireshark et al. to debug
and troubleshoot netlink traffic that is exchanged between user and
kernel space. We could even record pcap files for a later analysis.
No code change would be needed on the side of such analyzers, except
adding a simple protocol dissector, for example.

Please have a look at the main description in patch 3. Patch 1 and 2
are just prerequisits for the actual 3rd patch.

I think the device idea is the cleanest solution. We have packet sockets
and they do exactly what we want and expect from them, they have all the
features etc, and user space would not even need to implement code. Thus
adding more and more functionality into af_netlink would be a bigger
surgery and further bloat it up with duplicate code, imho. By taking the
approach with what I'm proposing, we have a clean segregation of
functionality (as: packet sockets vs. netlink sockets), thus keeping it
simple and stupid, and not too complex. 

Thanks !

Daniel Borkmann (3):
  net: if_arp: add ARPHRD_NETLINK type
  net: netlink: add registration/unregistration of virtual tap devices
  packet: nlmon: virtual netlink monitoring device for packet sockets

 drivers/net/Kconfig         |  10 +++
 drivers/net/Makefile        |   1 +
 drivers/net/nlmon.c         | 170 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/netlink.h     |  10 +++
 include/uapi/linux/if_arp.h |   1 +
 net/netlink/af_netlink.c    | 107 ++++++++++++++++++++++++++++
 6 files changed, 299 insertions(+)
 create mode 100644 drivers/net/nlmon.c

-- 
1.7.11.7
