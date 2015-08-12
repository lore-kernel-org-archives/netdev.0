From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/6] Geneve: Add support for tunnel metadata.
Date: Tue, 11 Aug 2015 22:17:26 -0700
Message-ID: <1439356646-21694-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33581 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbHLFSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 01:18:35 -0400
Received: by pdrh1 with SMTP id h1so3304937pdr.0
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 22:18:35 -0700 (PDT)
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


Pravin B Shelar (6):
  tunnel: introduce udp_tun_rx_dst()
  geneve: Make dst-port configurable.
  geneve: Add support to collect tunnel metadata.
  openvswitch: Use Geneve device.
  geneve: Consolidate Geneve functionality in single module.
  geneve: Remove duplicate dev list

 drivers/net/Kconfig            |   2 +-
 drivers/net/geneve.c           | 731 ++++++++++++++++++++++++++++++++++-------
 drivers/net/vxlan.c            |  18 +-
 include/net/dst_metadata.h     |  27 ++
 include/net/geneve.h           |  35 +-
 include/net/udp_tunnel.h       |   3 +
 include/uapi/linux/if_link.h   |   2 +
 net/ipv4/Kconfig               |  14 -
 net/ipv4/Makefile              |   1 -
 net/ipv4/geneve_core.c         | 447 -------------------------
 net/ipv4/ip_gre.c              |  21 +-
 net/ipv4/udp_tunnel.c          |  24 +-
 net/openvswitch/Kconfig        |   2 +-
 net/openvswitch/vport-geneve.c | 179 ++--------
 14 files changed, 719 insertions(+), 787 deletions(-)
 delete mode 100644 net/ipv4/geneve_core.c

-- 
1.8.3.1
