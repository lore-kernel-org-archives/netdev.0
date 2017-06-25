From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH net-next v2 0/5] net: add netlink_ext_ack support to rtnl_link_ops
Date: Sun, 25 Jun 2017 23:55:58 +0200
Message-ID: <cover.1498425679.git.mschiffer@universe-factory.net>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
        arvid.brodin-SVm98a2vdck@public.gmane.org, alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
        yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
        steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Same changes as http://patchwork.ozlabs.org/patch/780351/ , split into
separate patches for each rtnl_link_ops field as requested.


Matthias Schiffer (5):
  net: add netlink_ext_ack argument to rtnl_link_ops.newlink
  net: add netlink_ext_ack argument to rtnl_link_ops.changelink
  net: add netlink_ext_ack argument to rtnl_link_ops.validate
  net: add netlink_ext_ack argument to rtnl_link_ops.slave_changelink
  net: add netlink_ext_ack argument to rtnl_link_ops.slave_validate

 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 10 ++++++----
 drivers/net/bonding/bond_netlink.c           | 16 ++++++++++------
 drivers/net/caif/caif_hsi.c                  |  6 ++++--
 drivers/net/can/dev.c                        | 11 +++++++----
 drivers/net/can/vxcan.c                      |  3 ++-
 drivers/net/dummy.c                          |  3 ++-
 drivers/net/geneve.c                         |  6 ++++--
 drivers/net/gtp.c                            |  6 ++++--
 drivers/net/ifb.c                            |  3 ++-
 drivers/net/ipvlan/ipvlan.h                  |  3 ++-
 drivers/net/ipvlan/ipvlan_main.c             |  9 ++++++---
 drivers/net/ipvlan/ipvtap.c                  |  9 ++++-----
 drivers/net/macsec.c                         |  9 ++++++---
 drivers/net/macvlan.c                        |  9 ++++++---
 drivers/net/macvtap.c                        |  7 +++----
 drivers/net/nlmon.c                          |  3 ++-
 drivers/net/ppp/ppp_generic.c                |  6 ++++--
 drivers/net/team/team.c                      |  6 ++++--
 drivers/net/tun.c                            |  3 ++-
 drivers/net/veth.c                           |  8 +++++---
 drivers/net/vrf.c                            |  6 ++++--
 drivers/net/vxlan.c                          |  9 ++++++---
 include/net/rtnetlink.h                      | 15 ++++++++++-----
 net/8021q/vlan_netlink.c                     | 13 ++++++++-----
 net/bridge/br_netlink.c                      | 15 ++++++++++-----
 net/caif/chnl_net.c                          |  6 ++++--
 net/core/rtnetlink.c                         | 13 ++++++++-----
 net/hsr/hsr_netlink.c                        |  3 ++-
 net/ieee802154/6lowpan/core.c                |  6 ++++--
 net/ipv4/ip_gre.c                            | 16 ++++++++++------
 net/ipv4/ip_vti.c                            |  9 ++++++---
 net/ipv4/ipip.c                              |  9 ++++++---
 net/ipv6/ip6_gre.c                           | 14 +++++++++-----
 net/ipv6/ip6_tunnel.c                        |  9 ++++++---
 net/ipv6/ip6_vti.c                           |  9 ++++++---
 net/ipv6/sit.c                               |  9 ++++++---
 36 files changed, 190 insertions(+), 107 deletions(-)

-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
