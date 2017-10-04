From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/7] net: Plumb extack error reporting to enslavements
Date: Tue,  3 Oct 2017 21:58:47 -0700
Message-ID: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33081 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJDE7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:59:01 -0400
Received: by mail-pf0-f194.google.com with SMTP id m28so11147691pfi.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:59:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another round of extending extack error reporting, this time for
enslavements through ndo_add_slave and notifiers.

David Ahern (7):
  net: Add extack to netdev_notifier_info
  net: Add extack to ndo_add_slave
  net: Add extack to upper device linking
  net: vrf: Add extack messages for enslave errors
  net: bonding: Add extack messages for some enslave failures
  net: bridge: Pass extack to down to netdev_master_upper_dev_link
  mlxsw: spectrum: Add extack messages for enslave failures

 drivers/net/bonding/bond_main.c                    | 24 ++++--
 drivers/net/bonding/bond_options.c                 |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 46 ++++++++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c |  2 +-
 drivers/net/hyperv/netvsc_drv.c                    |  2 +-
 drivers/net/ipvlan/ipvlan_main.c                   |  2 +-
 drivers/net/macsec.c                               |  2 +-
 drivers/net/macvlan.c                              |  7 +-
 drivers/net/macvtap.c                              |  2 +-
 drivers/net/team/team.c                            |  5 +-
 drivers/net/usb/qmi_wwan.c                         |  2 +-
 drivers/net/vrf.c                                  | 23 ++++--
 include/linux/if_macvlan.h                         |  3 +-
 include/linux/netdevice.h                          | 19 ++++-
 include/net/bonding.h                              |  3 +-
 net/8021q/vlan.c                                   |  6 +-
 net/8021q/vlan.h                                   |  2 +-
 net/8021q/vlan_netlink.c                           |  2 +-
 net/batman-adv/hard-interface.c                    |  2 +-
 net/batman-adv/soft-interface.c                    |  3 +-
 net/bridge/br_device.c                             |  5 +-
 net/bridge/br_if.c                                 | 15 +++-
 net/bridge/br_ioctl.c                              |  2 +-
 net/bridge/br_private.h                            |  3 +-
 net/core/dev.c                                     | 96 +++++++++++++---------
 net/core/rtnetlink.c                               | 10 ++-
 net/openvswitch/vport-netdev.c                     |  3 +-
 27 files changed, 196 insertions(+), 97 deletions(-)

-- 
2.1.4
