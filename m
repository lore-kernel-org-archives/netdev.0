From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 02 Oct 2009 11:13:03 -0700 (PDT)
Message-ID: <20091002.111303.204669603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757924AbZJBSMr@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) connector credentials fix patch set from Philipp Reisner

2) IXGBE bug fixes from Peter P Waskiewicz Jr,Ben Greear,
   and Jiri Pirko.

3) sk->sk_mark not used consistently for routing lookups keys,
   fix from Atis Elsts

4) splice() nonblocking fix, from Eric Dumazet

5) pktgen delay handling regressed, fix from Eric Dumazet

6) ks8851_mll ethernet driver, from David Choi

7) TCP build warning fix from Andrew Morton

8) be2net RX completion bug workaround from Ajit Khaparde

9) Bonding doesn't set primary param properly, fix from Jiri Pirko.

10) Even if window scale is zero, TCP should advertise the option
    so that the other ends knows we support window scaling and thus
    they can advertise a non-zero scale if they want to.

    From Ori Finkelman.

11) qlge bug fixes from Ron Mercer.

12) SKY2 and SKGE irq names can conflict because the IRQ manages two de=
vices
    and if one of them gets it's name changed just right (by udev
    or whatever) the request_irq() fails.  Fix from Stephen Hemminger
    and Michal Schmidt.

13) Wireless bug fixes via John Linville.

Please pull, thanks a lot!

The following changes since commit 817b33d38f81c8736d39283c35c886ae4668=
f1af:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: Workaround to fix a bug in Rx Completion processing.

Andrew Morton (1):
      net/ipv4/tcp.c: fix min() type mismatch warning

Anton Vorontsov (1):
      3c59x: Rework suspend and resume

Atis Elsts (1):
      net: Use sk_mark for routing lookup in more places

Ben Greear (1):
      ixgbe patch to provide NIC's tx/rx counters via ethtool

Choi, David (1):
      drivers/net: ks8851_mll ethernet network driver

Christian Lamparter (1):
      ar9170: fix bug in iq-auto calibration value calculation

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Eric Dumazet (3):
      pktgen: Fix delay handling
      tg3: Remove prev_vlan_tag from struct tx_ring_info
      net: splice() from tcp to pipe should take into account O_NONBLOC=
K

=46rans Pop (1):
      e1000e/igb/ixgbe: Don't report an error if devices don't support =
AER

Igor Perminov (1):
      mac80211: Fix [re]association power saving issue on AP side

Jean Delvare (1):
      net: Fix wrong sizeof

Jiri Pirko (2):
      ixgbe: correct the parameter description
      bonding: set primary param via sysfs

Jouni Malinen (1):
      mac80211_hwsim: Fix initial beacon timer configuration

Michael Buesch (1):
      b43: Always use block-I/O for the PIO data registers

Michael Chan (1):
      cnic: Fix NETDEV_UP event processing.

Michal Schmidt (1):
      skge: use unique IRQ name

Michal Szalata (1):
      rt2x00: Thrustmaster FunAccess WIFI USB and rt73usb

Mike McCormack (1):
      skge: Make sure both ports initialize correctly

Ori Finkelman (1):
      IPv4 TCP fails to send window scale option when window scale is z=
ero

Peter P Waskiewicz Jr (4):
      ixgbe: Fix disabling of relaxed ordering with Tx DCA
      ixgbe: Fix backplane flow control autoneg
      ixgbe: Bump driver version number
      ixgbe: Remove ATR computation for UDP traffic

Philipp Reisner (8):
      connector: Keep the skb in cn_callback_data
      connector: Provide the sender's credentials to the callback
      connector/dm: Fixed a compilation warning
      connector: Removed the destruct_data callback since it is always =
kfree_skb()
      dm/connector: Only process connector packages from privileged pro=
cesses
      dst/connector: Disallow unpliviged users to configure dst
      pohmelfs/connector: Disallow unpliviged users to configure pohmel=
fs
      uvesafb/connector: Disallow unpliviged users to send netlink pack=
ets

Ralf Baechle (2):
      NET: mkiss: Fix typo
      Kconfig: STRIP: Remove stale bits of STRIP help text

Ron Mercer (5):
      qlge: Fix bad bit definitions.
      qlge: Fix out of sync hardware semaphore.
      qlge: Fix spin_lock warning.
      qlge: Protect reset recovery with rtnl_lock().
      qlge: Fix error exit for probe call.

Stephen Hemminger (1):
      sky2: irqname based on pci address

Uwe Kleine-K=F6nig (3):
      don't use __devexit_p to wrap meth_remove
      don't use __devexit_p to wrap sgiseeq_remove
      move virtnet_remove to .devexit.text

roel kluin (1):
      bcm63xx_enet: timeout off by one in do_mdio_op()

 Documentation/connector/cn_test.c                  |    2 +-
 Documentation/connector/connector.txt              |    8 +-
 .../networking/timestamping/timestamping.c         |    2 +-
 drivers/connector/cn_queue.c                       |   12 +-
 drivers/connector/connector.c                      |   22 +-
 drivers/md/dm-log-userspace-transfer.c             |    6 +-
 drivers/net/3c59x.c                                |   77 +-
 drivers/net/Kconfig                                |    7 +
 drivers/net/Makefile                               |    1 +
 drivers/net/bcm63xx_enet.c                         |    2 +-
 drivers/net/benet/be.h                             |    1 +
 drivers/net/benet/be_cmds.c                        |    3 +-
 drivers/net/benet/be_cmds.h                        |    3 +-
 drivers/net/benet/be_main.c                        |   23 +-
 drivers/net/bonding/bond_sysfs.c                   |    1 +
 drivers/net/cnic.c                                 |    3 +-
 drivers/net/cnic_if.h                              |    4 +-
 drivers/net/e1000e/netdev.c                        |   13 +-
 drivers/net/hamradio/mkiss.c                       |    4 +-
 drivers/net/igb/igb_main.c                         |   13 +-
 drivers/net/iseries_veth.c                         |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c                    |    2 +-
 drivers/net/ixgbe/ixgbe_common.c                   |  232 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c                  |    4 +
 drivers/net/ixgbe/ixgbe_main.c                     |   52 +-
 drivers/net/ixgbe/ixgbe_type.h                     |    9 +
 drivers/net/ks8851_mll.c                           | 1697 ++++++++++++=
++++++++
 drivers/net/meth.c                                 |    2 +-
 drivers/net/qlge/qlge.h                            |   18 +-
 drivers/net/qlge/qlge_main.c                       |   26 +-
 drivers/net/sgiseeq.c                              |    2 +-
 drivers/net/skge.c                                 |   16 +-
 drivers/net/skge.h                                 |    2 +
 drivers/net/sky2.c                                 |    7 +-
 drivers/net/sky2.h                                 |    2 +
 drivers/net/tg3.h                                  |    1 -
 drivers/net/virtio_net.c                           |    2 +-
 drivers/net/wireless/Kconfig                       |   13 +-
 drivers/net/wireless/ath/ar9170/phy.c              |    6 +-
 drivers/net/wireless/b43/pio.c                     |   60 +-
 drivers/net/wireless/mac80211_hwsim.c              |    3 +
 drivers/net/wireless/rt2x00/rt73usb.c              |    1 +
 drivers/staging/dst/dcore.c                        |    7 +-
 drivers/staging/pohmelfs/config.c                  |    5 +-
 drivers/video/uvesafb.c                            |    5 +-
 drivers/w1/w1_netlink.c                            |    2 +-
 include/linux/connector.h                          |   11 +-
 net/core/pktgen.c                                  |    6 +-
 net/ipv4/af_inet.c                                 |    1 +
 net/ipv4/ip_output.c                               |    1 +
 net/ipv4/tcp.c                                     |    4 +-
 net/ipv4/tcp_output.c                              |   11 +-
 net/ipv4/udp.c                                     |    1 +
 net/mac80211/tx.c                                  |    5 +-
 54 files changed, 2157 insertions(+), 268 deletions(-)
 create mode 100644 drivers/net/ks8851_mll.c
