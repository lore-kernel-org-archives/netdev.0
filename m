From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 12 May 2012 04:20:28 -0400 (EDT)
Message-ID: <20120512.042028.912019707767582333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Since we do RCU lookups on ipv4 FIB entries, we have to test if the
   entry is dead before returning it to our caller.

2) openvswitch locking and packet validation fixes from Ansis Atteka,
   Jesse Gross, and Pravin B Shelar.

3) Fix PM resume locking in IGB driver, from Benjamin Poirier.

4) Fix VLAN header handling in vhost-net and macvtap, from Basil Gor.

5) Revert a bogus network namespace isolation change that was causing
   regressions on S390 networking devices.

6) If bonding decides to process and handle a LACPDU frame, we shouldn'=
t
   bump the rx_dropped counter.  From Jiri Bohac.

7) Fix mis-calculation of available TX space in r8169 driver when
   doing TSO, which can lead to crashes and/or hung device.  From
   Julien Ducourthial.

8) SCTP does not validate cached routes properly in all cases, from
   Nicolas Dichtel.

9) Link status interrupt needs to be handled in ks8851 driver, from
   Stephen Boyd.

10) Use capable(), not cap_raised(), in connector/userns netlink code.
    From Eric W. Biederman via Andrew Morton.

11) Fix pktgen OOPS on module unload, from Eric Dumazet.

12) iwlwifi under-estimates SKB truesizes, also from Eric Dumazet.

13) Cure division by zero in SFC driver, from Ben Hutchings.

Please pull, thanks a lot!

The following changes since commit 0a6ba092d1c8c75ae0c0617ef7f4e6f5043a=
f311:

  Merge tag 'mfd-for-linus-3.4-rc6' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/sameo/mfd-2.6 (2012-05-03 17:21:05 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 062e55e3960062fc2fb62a7274b4c253003eba73=
:

  ks8851: Update link status during link change interrupt (2012-05-11 1=
8:23:34 -0400)

----------------------------------------------------------------
Andrei Emeltchenko (1):
      e1000: Silence sparse warnings by correcting type

Ansis Atteka (1):
      openvswitch: Release rtnl_lock if ovs_vport_cmd_build_info() fail=
ed.

Ariel Elior (1):
      bnx2x: bug fix when loading after SAN boot

Basil Gor (2):
      vhost-net: fix handle_rx buffer size
      macvtap: restore vlan header on user read

Ben Hutchings (1):
      sfc: Fix division by zero when using one RX channel and no SR-IOV

Benjamin Poirier (1):
      igb: fix rtnl race in PM resume path

Bj=F8rn Mork (1):
      cdc_ether: Ignore bogus union descriptor for RNDIS devices

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h
      Merge branch 'sfc-3.4' of git://git.kernel.org/.../bwh/sfc
      ipv4: Do not use dead fib_info entries.
      Revert "net: maintain namespace isolation between vlan and real d=
evice"

Don Skidmore (1):
      ixgbe: fix race condition with shutdown

Eric Dumazet (2):
      iwlwifi: fix skb truesize underestimation
      pktgen: fix crash at module unload

Eric W. Biederman (1):
      connector/userns: replace netlink uses of cap_raised() with capab=
le()

=46ranky Lin (1):
      brcmfmac: fix a double spin_unlock_irqrestore issue in dpc

Jesse Gross (1):
      openvswitch: Add length check when retrieving TCP flags.

Jiri Bohac (1):
      bonding: don't increase rx_dropped after processing LACPDUs

Johannes Berg (1):
      net: compare_ether_addr[_64bits]() has no ordering

John Fastabend (2):
      ixgbe: dcb: BIT_APP_UPCHG not set by ixgbe_copy_dcb_cfg()
      igb, ixgbe: netdev_tx_reset_queue incorrectly called from tx init=
 path

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julien Ducourthial (1):
      r8169: fix unsigned int wraparound with TSO

Nicolas Dichtel (1):
      sctp: check cached dst before using it

Pravin B Shelar (1):
      openvswitch: Validation of IPv6 set port action uses IPv4 header

Rajkumar Manoharan (1):
      Revert "ath9k_hw: Fix incorrect spur_freq_sd for AR9003"

Stephen Boyd (1):
      ks8851: Update link status during link change interrupt

Thadeu Lima de Souza Cascardo (1):
      ehea: fix losing of NEQ events when one event occurred early

 drivers/block/drbd/drbd_nl.c                       |    2 +-
 drivers/md/dm-log-userspace-transfer.c             |    2 +-
 drivers/net/bonding/bond_3ad.c                     |   18 ++++++++++++=
------
 drivers/net/bonding/bond_3ad.h                     |    2 +-
 drivers/net/bonding/bond_main.c                    |   16 +++++++++++-=
----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   23 ++++++++++++=
++++++++++-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    2 ++
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c          |   24 ++++++++----=
------------
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    3 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   43 ++++++++++++=
++++++++-----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   10 ++++++----
 drivers/net/ethernet/micrel/ks8851.c               |    7 ++++---
 drivers/net/ethernet/realtek/r8169.c               |   16 ++++++++++--=
----
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/macvlan.c                              |    2 +-
 drivers/net/macvtap.c                              |   43 ++++++++++++=
++++++++++++++++++++++++++-----
 drivers/net/usb/cdc_ether.c                        |   14 ++++++++++++=
--
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   21 ++++++++++++=
++-------
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |    3 ++-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    1 +
 drivers/vhost/net.c                                |    7 ++++++-
 drivers/video/uvesafb.c                            |    2 +-
 include/linux/etherdevice.h                        |   11 ++++++-----
 include/linux/netdevice.h                          |    9 ---------
 include/net/sctp/sctp.h                            |   13 ++++++++++++=
+
 net/8021q/vlan_dev.c                               |    2 +-
 net/core/dev.c                                     |   36 +++++-------=
------------------------
 net/core/pktgen.c                                  |   10 ++++++++--
 net/ipv4/fib_trie.c                                |    2 ++
 net/openvswitch/datapath.c                         |   27 ++++++++++++=
+++++----------
 net/openvswitch/flow.c                             |    3 ++-
 net/sctp/output.c                                  |    4 +---
 net/sctp/transport.c                               |   17 ------------=
-----
 37 files changed, 236 insertions(+), 172 deletions(-)
