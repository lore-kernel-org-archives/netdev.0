From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 0/6] Allow to switch off UDP-based tunnel offloads per netdevice
Date: Fri, 30 Jun 2017 15:19:44 +0200
Message-ID: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a new netdevice feature to toggle tunnel offloads
via ethtool. This is useful if the offload is causing issues, for
example if the hardware is buggy.

The feature is added to all devices providing the ->ndo_udp_tunnel_add
op, and enabled by default to preserve current behavior.

When the administrator disables this feature on a device, all
currently offloaded ports are cleared from the device.  When the
feature is turned on, the stack notifies the device about all current
ports.

Sabrina Dubroca (6):
  net: add new netdevice feature for tunnel offloading
  net: check tunnel offload feature before calling tunnel ndo ndo
  net: add infrastructure to un-offload UDP tunnel port
  net: call udp_tunnel_get_rx_info when NETIF_F_TUNNEL_OFFLOAD is
    toggled
  geneve/vxlan: add support for NETDEV_UDP_TUNNEL_DROP_INFO
  geneve/vxlan: offload ports on register/unregister events

 drivers/net/geneve.c            | 24 ++++++++++++++++++------
 drivers/net/vxlan.c             | 31 ++++++++++++++++++++++---------
 include/linux/netdev_features.h |  2 ++
 include/linux/netdevice.h       |  1 +
 include/net/udp_tunnel.h        |  8 ++++++++
 net/core/dev.c                  | 28 +++++++++++++++++++++++++++-
 net/core/ethtool.c              |  1 +
 net/ipv4/udp_tunnel.c           | 25 ++++++++++++++++++++++++-
 8 files changed, 103 insertions(+), 17 deletions(-)

-- 
2.13.2
