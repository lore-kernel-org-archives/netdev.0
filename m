From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 06 Jan 2015 20:35:42 -0500 (EST)
Message-ID: <20150106.203542.1515714670133944465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just a pile of random fixes, including:

1) Do not apply TSO limits to non-TSO packets, fix from Herbert
   Xu.

2) MDI{,X} eeprom check in e100 driver is reversed, from
   John W. Linville.

3) Missing error return assignments in several ethernet drivers,
   from Julia Lawall.

4) Altera TSE device doesn't come back up after ifconfig down/up
   sequence, fix from Kostya Belezko.

5) Add more cases to the check for whether the qmi_wwan device has
   a bogus MAC address and needs to be assigned a random one.  From
   Kristian Evensen.

6) Fix interrupt hangs in CPSW, from Felipe Balbi.

7) Implement ndo_features_check in r8152 so that the stack doesn't
   feed GSO packets which are outside of the chip's capabilities.
   From Hayes Wang.

Please pull, thanks a lot!

The following changes since commit 2c90331cf5ed1d648a711b9483e173aaaf2c=
4a9b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-1=
2-30 10:45:47 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 2abad79afa700e837cb4feed170141292e0720c0=
:

  qla3xxx: don't allow never end busy loop (2015-01-06 17:41:36 -0500)

----------------------------------------------------------------
Andy Shevchenko (1):
      qla3xxx: don't allow never end busy loop

Ben Pfaff (1):
      openvswitch: Consistently include VLAN header in flow and port st=
ats.

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'mlx4-net'
      Merge tag 'mac80211-for-davem-2015-01-06' of git://git.kernel.org=
/.../jberg/mac80211
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge

=46elipe Balbi (1):
      net: ethernet: cpsw: fix hangs with interrupts

Govindarajulu Varadarajan (1):
      enic: free all rq buffs when allocation fails

Herbert Xu (1):
      tcp: Do not apply TSO segment limit to non-TSO packets

Jack Morgenstein (1):
      net/mlx4_core: Fix error flow in mlx4_init_hca()

Joe Perches (1):
      i40e: Fix possible memory leak in i40e_dbg_dump_desc

Johannes Berg (1):
      Revert "mac80211: Fix accounting of the tailroom-needed counter"

John W. Linville (1):
      e100: fix typo in MDI/MDI-X eeprom check in e100_phy_init

Julia Lawall (4):
      net: Xilinx: fix error return code
      myri10ge: fix error return code
      net: sun4i-emac: fix error return code
      net: axienet: fix error return code

Kostya Belezko (1):
      Altera TSE: Add missing phydev

Kristian Evensen (1):
      qmi_wwan: Set random MAC on devices with buggy fw

Linus L=FCssing (4):
      batman-adv: fix delayed foreign originator recognition
      batman-adv: fix counter for multicast supporting nodes
      batman-adv: fix multicast counter when purging originators
      batman-adv: fix potential TT client + orig-node memory leak

Maor Gottlieb (1):
      net/mlx4_core: Correcly update the mtt's offset in the MR re-reg =
flow

Martin Hundeb=F8ll (1):
      batman-adv: fix lock class for decoding hash in network-coding.c

Palik, Imre (1):
      xen-netback: fixing the propagation of the transmit shaper timeou=
t

Simon Wunderlich (1):
      batman-adv: fix and simplify condition when bonding should be use=
d

Todd Fujinaka (1):
      igb: Remove unneeded FIXME

Yongjian Xu (1):
      qlcnic: Fix return value in qlcnic_probe()

hayeswang (1):
      r8152: support ndo_features_check

 drivers/net/ethernet/allwinner/sun4i-emac.c       |  4 +++-
 drivers/net/ethernet/altera/altera_tse_main.c     | 15 ++++++---------
 drivers/net/ethernet/cisco/enic/enic_main.c       |  6 ++++--
 drivers/net/ethernet/intel/e100.c                 |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    |  4 +++-
 drivers/net/ethernet/intel/igb/e1000_82575.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c         | 13 ++++---------
 drivers/net/ethernet/mellanox/mlx4/mr.c           |  9 +++++----
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  |  4 +++-
 drivers/net/ethernet/qlogic/qla3xxx.c             |  8 +++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  1 +
 drivers/net/ethernet/ti/cpsw.c                    | 19 ++++++++-------=
----
 drivers/net/ethernet/xilinx/ll_temac_main.c       |  2 ++
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |  2 ++
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |  1 +
 drivers/net/usb/qmi_wwan.c                        | 10 +++++++---
 drivers/net/usb/r8152.c                           | 17 +++++++++++++++=
++
 drivers/net/xen-netback/xenbus.c                  |  1 +
 include/net/mac80211.h                            |  7 ++-----
 net/batman-adv/multicast.c                        | 11 +++++++----
 net/batman-adv/network-coding.c                   |  2 +-
 net/batman-adv/originator.c                       |  7 ++++---
 net/batman-adv/routing.c                          |  6 ++++--
 net/ipv4/tcp_output.c                             |  4 ++--
 net/mac80211/key.c                                | 12 +++++++++---
 net/openvswitch/flow.c                            |  5 +++--
 net/openvswitch/vport.c                           |  2 +-
 27 files changed, 105 insertions(+), 71 deletions(-)
