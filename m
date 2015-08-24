From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 0/8] Geneve: Add support for tunnel metadata mode
Date: Mon, 24 Aug 2015 10:43:07 -0700
Message-ID: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36086 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbbHXRnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:19 -0400
Received: by pdbmi9 with SMTP id mi9so55808850pdb.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:19 -0700 (PDT)
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

 drivers/net/Kconfig            |    2 +-
 drivers/net/geneve.c           |  730 ++++++++++++++++++++++++++++++++++------
 drivers/net/vxlan.c            |   29 +--
 include/net/dst_metadata.h     |   61 ++++
 include/net/geneve.h           |   35 +--
 include/net/udp_tunnel.h       |    4 +
 include/uapi/linux/if_link.h   |    2 +
 net/ipv4/Kconfig               |   14 -
 net/ipv4/Makefile              |    1 -
 net/ipv4/geneve_core.c         |  447 ------------------------
 net/ipv4/ip_gre.c              |   20 +-
 net/ipv4/udp_tunnel.c          |   25 ++-
 net/openvswitch/Kconfig        |    2 +-
 net/openvswitch/vport-geneve.c |  179 ++--------
 14 files changed, 760 insertions(+), 791 deletions(-)
 delete mode 100644 net/ipv4/geneve_core.c
