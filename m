From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 10 Feb 2017 16:26:14 -0500 (EST)
Message-ID: <20170210.162614.2105852361351738110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) If the timing is wrong we can indefinitely stop generating new
   ipv6 temporary addresses, from Marcus Huewe.

2) Don't double free per-cpu stats in ipv6 SIT tunnel driver, from
   Cong Wang.

3) Put protections in place so that AF_PACKET is not able to submit
   packets which don't even have a link level header to drivers.  From
   Willem de Bruijn.

4) Fix memory leaks in ipv4 and ipv6 multicast code, from Hangbin Liu.

5) Don't use udp_ioctl() in l2tp code, UDP version expects a UDP socket
   and that doesn't go over very well when it is passed an L2TP one.
   Fix from Eric Dumazet.

6) Don't crash on NULL pointer in phy_attach_direct(), from Florian
   Fainelli.

Please pull, thanks a lot.

The following changes since commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-02-07 12:10:57 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 72fb96e7bdbbdd4421b0726992496531060f3636:

  l2tp: do not use udp_ioctl() (2017-02-10 15:57:34 -0500)

----------------------------------------------------------------
Boris Ostrovsky (1):
      xen-netfront: Delete rx_refill_timer in xennet_disconnect_backend()

David Ahern (1):
      lwtunnel: valid encap attr check should return 0 when lwtunnel is disabled

David S. Miller (2):
      Merge branch 'net-header-length-truncation'
      Merge branch 'sierra_net-fixes'

Eric Dumazet (1):
      l2tp: do not use udp_ioctl()

Florian Fainelli (2):
      net: dsa: Do not destroy invalid network devices
      net: phy: Fix PHY module checks and NULL deref in phy_attach_direct()

Hangbin Liu (1):
      igmp, mld: Fix memory leak in igmpv3/mld_del_delrec()

Kejian Yan (1):
      net: hns: Fix the device being used for dma mapping during TX

Marcus Huewe (1):
      ipv6: addrconf: fix generation of new temporary addresses

Ralf Baechle (1):
      NET: mkiss: Fix panic

Ross Lagerwall (1):
      xen-netfront: Improve error handling during initialization

Stefan Brüns (2):
      sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
      sierra_net: Skip validating irrelevant fields for IDLE LSIs

Thanneeru Srinivasulu (1):
      net: thunderx: Fix PHY autoneg for SGMII QLM mode

Vineeth Remanan Pillai (1):
      xen-netfront: Rework the fix for Rx stall during OOM and network stress

WANG Cong (3):
      sit: fix a double free on error path
      ping: fix a null pointer dereference
      kcm: fix 0-length case for kcm_sendmsg()

Willem de Bruijn (2):
      net: introduce device min_header_len
      packet: round up linear to header len

Yendapally Reddy Dhananjaya Reddy (1):
      net: phy: Initialize mdio clock at probe function

 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |   5 +++++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     |   2 +-
 drivers/net/hamradio/mkiss.c                      |   4 ++--
 drivers/net/loopback.c                            |   1 +
 drivers/net/phy/mdio-bcm-iproc.c                  |   6 ++----
 drivers/net/phy/phy_device.c                      |  28 ++++++++++++++++++++--------
 drivers/net/usb/sierra_net.c                      | 111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------------------
 drivers/net/xen-netfront.c                        |  46 ++++++++++++++++++++++++----------------------
 include/linux/netdevice.h                         |   4 ++++
 include/net/lwtunnel.h                            |   5 ++++-
 net/dsa/dsa2.c                                    |   1 +
 net/ethernet/eth.c                                |   1 +
 net/ipv4/igmp.c                                   |   1 +
 net/ipv4/ping.c                                   |   2 ++
 net/ipv6/addrconf.c                               |   6 ++++++
 net/ipv6/mcast.c                                  |   1 +
 net/ipv6/sit.c                                    |   1 +
 net/kcm/kcmsock.c                                 |  40 ++++++++++++++++++++++------------------
 net/l2tp/l2tp_core.h                              |   1 +
 net/l2tp/l2tp_ip.c                                |  27 ++++++++++++++++++++++++++-
 net/l2tp/l2tp_ip6.c                               |   2 +-
 net/packet/af_packet.c                            |   7 ++++---
 23 files changed, 297 insertions(+), 113 deletions(-)
