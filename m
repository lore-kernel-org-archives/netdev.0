From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v5 net-next 0/8] geneve: Add support for tunnel metadata mode
Date: Wed, 26 Aug 2015 23:46:47 -0700
Message-ID: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34093 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbH0Gq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:46:59 -0400
Received: by pabzx8 with SMTP id zx8so15096522pab.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:46:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds support for Geneve tunnel metadata
mode. OVS can make use of Geneve net-device with tunnel
metadata API from kernel.

This also allows us to consolidate Geneve implementation
from two kernel modules geneve_core and geneve to single
geneve module. geneve_core module was targeted to share
Geneve encap and decap code between Geneve netdevice and
OVS Geneve tunnel implementation, Since OVS no longer
needs these API, Geneve code can be consolidated into
single geneve module.

v4-v5:
- Fix xnet calculation. 

v3-v4:
- Drop NETIF_F_NETNS_LOCAL feature.
- Fix geneve device newlink check

v2-v3:
- make tunnel medata device and regular device mutually exclusive.
- Fix Kconfig dependency for Geneve.
- Fix dst-port netlink encoding.
- drop changelink patch.

v1-v2:
- Replaced per hash table tunnel pointer (metadata enabled) with flag.
- Added support for changelink.
- Improve geneve device route lookup with more parameters.

Pravin B Shelar (8):
  geneve: Initialize ethernet address in device setup.
  geneve: Use skb mark and protocol to lookup route.
  tunnel: introduce udp_tun_rx_dst()
  geneve: Make dst-port configurable.
  geneve: Add support to collect tunnel metadata.
  openvswitch: Use Geneve device.
  geneve: Consolidate Geneve functionality in single module.
  geneve: Move device hash table to geneve socket.

 drivers/net/Kconfig            |    4 +-
 drivers/net/geneve.c           |  736 ++++++++++++++++++++++++++++++++++------
 drivers/net/vxlan.c            |   29 +--
 include/net/dst_metadata.h     |   61 ++++
 include/net/geneve.h           |   35 +--
 include/net/udp_tunnel.h       |    4 +
 include/uapi/linux/if_link.h   |    2 +
 net/ipv4/Kconfig               |   14 -
 net/ipv4/Makefile              |    1 -
 net/ipv4/geneve_core.c         |  447 ------------------------
 net/ipv4/ip_gre.c              |   21 +-
 net/ipv4/udp_tunnel.c          |   25 ++-
 net/openvswitch/Kconfig        |    2 +-
 net/openvswitch/vport-geneve.c |  179 ++--------
 14 files changed, 767 insertions(+), 793 deletions(-)
 delete mode 100644 net/ipv4/geneve_core.c
