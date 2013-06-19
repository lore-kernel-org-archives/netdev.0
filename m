From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 0/3] Virtual netlink device for packet sockets
Date: Wed, 19 Jun 2013 20:04:43 +0200
Message-ID: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934984Ab3FSSFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:05:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set allows for a virtual netlink device that can be easily used
without modification by tools like tcpdump, Wireshark et al. to debug
and troubleshoot netlink traffic that is exchanged between user and
kernel space. We could even record pcap files for a later analysis.
No code change would be needed on the side of such analyzers, except
adding a simple protocol dissector, for example.

Please have a look at the main description in patch 3. Patch 1 and 2
are just prerequisits for the actual 3rd patch. In the cover letter I
just want to bring up one design item we could discuss, if needed.

The current design is pluggable, which means we have a simple module
that can be used when we want to debug netlink issues and that can be
unloaded when done. By that, we can place the driver under drivers/net/
just like many others (lo, veth, ..., usbmon, etc.) and leave the core
mostly untouched, besides patch 2. If we do not want to allow for
pluggable modules, we would need to migrate this code into net/netlink/
and directly integrate it with af_netlink. That's another option. Then,
we can only compile it as built-in, or not.

This is posted as an RFC, so if you have any feedback, I'm happy to
apply it to the set before posting it as a non-RFC.

Thanks !

Daniel Borkmann (3):
  net: if_arp: add ARPHRD_NETLINK type
  net: netlink: add registration/unregistration of virtual tap devices
  packet: nlmon: virtual netlink monitoring device for packet sockets

 drivers/net/Kconfig         |  11 +++
 drivers/net/Makefile        |   1 +
 drivers/net/nlmon.c         | 169 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/netlink.h     |  11 +++
 include/uapi/linux/if_arp.h |   1 +
 net/netlink/af_netlink.c    |  72 +++++++++++++++++++
 6 files changed, 265 insertions(+)
 create mode 100644 drivers/net/nlmon.c

-- 
1.7.11.7
