From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/3] net: extend netdevice notifier and use it for flags change
Date: Tue, 28 May 2013 10:24:17 +0200
Message-ID: <1369729460-28421-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:44371 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933383Ab3E1IYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:24:24 -0400
Received: by mail-wi0-f171.google.com with SMTP id hq7so2224526wib.10
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:24:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  net: pass info struct via netdevice notifier
  net: pass changed flags along with NETDEV_CHANGE event

Timo Ter=C3=A4s (1):
  arp: flush arp cache on IFF_NOARP change

 arch/ia64/hp/sim/simeth.c                          |  2 +-
 arch/mips/txx9/generic/setup_tx4939.c              |  3 +-
 drivers/infiniband/core/cma.c                      |  4 +-
 drivers/infiniband/hw/mlx4/main.c                  |  2 +-
 drivers/net/bonding/bond_main.c                    |  2 +-
 drivers/net/can/led.c                              |  4 +-
 drivers/net/ethernet/broadcom/cnic.c               |  2 +-
 drivers/net/ethernet/marvell/skge.c                |  2 +-
 drivers/net/ethernet/marvell/sky2.c                |  2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
 drivers/net/ethernet/sfc/efx.c                     |  2 +-
 drivers/net/hamradio/bpqether.c                    |  7 ++-
 drivers/net/macvlan.c                              |  2 +-
 drivers/net/macvtap.c                              |  2 +-
 drivers/net/netconsole.c                           |  5 +-
 drivers/net/ppp/pppoe.c                            |  2 +-
 drivers/net/team/team.c                            |  2 +-
 drivers/net/wan/dlci.c                             |  2 +-
 drivers/net/wan/hdlc.c                             |  2 +-
 drivers/net/wan/lapbether.c                        |  2 +-
 drivers/scsi/fcoe/fcoe.c                           |  2 +-
 drivers/scsi/fcoe/fcoe_transport.c                 |  2 +-
 drivers/staging/csr/netdev.c                       |  2 +-
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c |  2 +-
 drivers/staging/ft1000/ft1000-usb/ft1000_proc.c    |  2 +-
 drivers/staging/silicom/bpctl_mod.c                |  2 +-
 include/linux/netdevice.h                          | 18 ++++++
 net/8021q/vlan.c                                   |  2 +-
 net/appletalk/aarp.c                               |  2 +-
 net/appletalk/ddp.c                                |  2 +-
 net/atm/clip.c                                     |  4 +-
 net/atm/mpc.c                                      |  6 +-
 net/ax25/af_ax25.c                                 |  6 +-
 net/batman-adv/hard-interface.c                    |  2 +-
 net/bridge/br_notify.c                             |  2 +-
 net/caif/caif_dev.c                                |  4 +-
 net/caif/caif_usb.c                                |  4 +-
 net/can/af_can.c                                   |  4 +-
 net/can/bcm.c                                      |  4 +-
 net/can/gw.c                                       |  4 +-
 net/can/raw.c                                      |  4 +-
 net/core/dev.c                                     | 65 ++++++++++++++=
++++----
 net/core/drop_monitor.c                            |  4 +-
 net/core/dst.c                                     |  2 +-
 net/core/fib_rules.c                               |  4 +-
 net/core/netprio_cgroup.c                          |  2 +-
 net/core/pktgen.c                                  |  2 +-
 net/core/rtnetlink.c                               |  2 +-
 net/decnet/af_decnet.c                             |  4 +-
 net/ieee802154/6lowpan.c                           |  5 +-
 net/ipv4/arp.c                                     |  8 ++-
 net/ipv4/devinet.c                                 |  2 +-
 net/ipv4/fib_frontend.c                            |  2 +-
 net/ipv4/ipmr.c                                    |  2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |  2 +-
 net/ipv6/addrconf.c                                |  4 +-
 net/ipv6/ip6mr.c                                   |  2 +-
 net/ipv6/ndisc.c                                   |  2 +-
 net/ipv6/netfilter/ip6t_MASQUERADE.c               |  2 +-
 net/ipv6/route.c                                   |  4 +-
 net/ipx/af_ipx.c                                   |  2 +-
 net/iucv/af_iucv.c                                 |  2 +-
 net/mac80211/iface.c                               |  5 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     |  4 +-
 net/netfilter/nfnetlink_queue_core.c               |  2 +-
 net/netfilter/xt_TEE.c                             |  2 +-
 net/netlabel/netlabel_unlabeled.c                  |  7 +--
 net/netrom/af_netrom.c                             |  2 +-
 net/openvswitch/dp_notify.c                        |  2 +-
 net/packet/af_packet.c                             |  5 +-
 net/phonet/pn_dev.c                                |  4 +-
 net/rose/af_rose.c                                 |  6 +-
 net/sched/act_mirred.c                             |  2 +-
 net/tipc/eth_media.c                               |  4 +-
 net/tipc/ib_media.c                                |  4 +-
 net/wireless/core.c                                |  5 +-
 net/x25/af_x25.c                                   |  2 +-
 net/xfrm/xfrm_policy.c                             |  2 +-
 security/selinux/netif.c                           |  2 +-
 80 files changed, 190 insertions(+), 129 deletions(-)

--=20
1.7.11.7
