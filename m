From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 0/9] Geneve: Add support for tunnel metadata mode
Date: Mon, 17 Aug 2015 14:11:36 -0700
Message-ID: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35597 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbbHQVLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:11:50 -0400
Received: by pdob1 with SMTP id b1so4288796pdo.2
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:11:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds spport for Geneve tunnel metadata
mode. OVS can make use of Geneve net-device with tunnel
metadata API from kernel.

This also allows us to consolidate Geneve implementation
from two kernel modules geneve_core and geneve to single
geneve module. geneve_core module was targeted to share
Geneve encap and decap code between Geneve netdevice and
OVS Geneve tunnel implementation, Since OVS no longer
needs these API, Geneve code can be consolidated into
single geneve module.

v1-v2:
- Replaced per hash table tunnel pointer (metadata enabled) with flag.
- Added support for changelink.
- Improve geneve device route lookup with more parameters.

Pravin B Shelar (9):
  geneve: Initialize ethernet address in device setup.
  geneve: Use skb mark and protocol to lookup route.
  tunnel: introduce udp_tun_rx_dst()
  geneve: Make dst-port configurable.
  geneve: Add support to collect tunnel metadata.
  openvswitch: Use Geneve device.
  geneve: Consolidate Geneve functionality in single module.
  geneve: Move device hash table to geneve socket.
  geneve: Implement rtnl changelink

 drivers/net/Kconfig            |   2 +-
 drivers/net/geneve.c           | 804 +++++++++++++++++++++++++++++++++++------
 drivers/net/vxlan.c            |  18 +-
 include/net/dst_metadata.h     |  27 ++
 include/net/geneve.h           |  35 +-
 include/net/udp_tunnel.h       |   3 +
 include/uapi/linux/if_link.h   |   2 +
 net/ipv4/Kconfig               |  14 -
 net/ipv4/Makefile              |   1 -
 net/ipv4/geneve_core.c         | 447 -----------------------
 net/ipv4/ip_gre.c              |  21 +-
 net/ipv4/udp_tunnel.c          |  24 +-
 net/openvswitch/Kconfig        |   2 +-
 net/openvswitch/vport-geneve.c | 179 ++-------
 14 files changed, 791 insertions(+), 788 deletions(-)
 delete mode 100644 net/ipv4/geneve_core.c

-- 
1.8.3.1
