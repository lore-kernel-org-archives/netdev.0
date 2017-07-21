From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 0/6] Allow to switch off UDP-based tunnel offloads per netdevice
Date: Fri, 21 Jul 2017 12:49:27 +0200
Message-ID: <cover.1500632570.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753383AbdGUKtw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a new netdevice feature to toggle RX offloads of
UDP-based tunnel via ethtool. This is useful if the offload is causing
issues, for example if the hardware is buggy.

The feature is added to all devices providing the ->ndo_udp_tunnel_add
op, and enabled by default to preserve current behavior.

When the administrator disables this feature on a device, all
currently offloaded ports are cleared from the device.  When the
feature is turned on, the stack notifies the device about all current
ports.

v2:
 - rename feature bit to NETIF_F_RX_UDP_TUNNEL_PORT
 - rename ethtool feature to rx-udp_tunnel-port-offload


Sabrina Dubroca (6):
  net: add new netdevice feature for offload of RX port for UDP tunnels
  net: check UDP tunnel RX port offload feature before calling tunnel
    ndo ndo
  net: add infrastructure to un-offload UDP tunnel port
  net: call udp_tunnel_get_rx_info when NETIF_F_RX_UDP_TUNNEL_PORT is
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
