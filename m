From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 16 Nov 2012 17:07:35 -0500 (EST)
Message-ID: <20121116.170735.1048151403513326838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) tx_filtered/ps_tx_buf queues need to be accessed with the SKB queue
   lock, from Arik Nemtsov.

2) Don't call 802.11 driver's filter configure method until it's
   actually open, from Felix Fietkau.

3) Use ieee80211_free_txskb otherwise we leak control information.
   From Johannes Berg.

4) Fix memory leak in bluetooth UUID removal,f rom Johan Hedberg.

5) The shift mask trick doesn't work properly when 'optname' is
   out of range in do_ip_setsockopt().  Use a straightforward
   switch statement instead, the compiler emits essentially the
   same code but without the missing range check.  From Xi Wang.

6) Fix when we call tcp_replace_ts_recent() otherwise we can
   erroneously accept a too-high tsval.  From Eric Dumazet.

7) VXLAN bug fixes, mostly to do with VLAN header length handling,
   from Alexander Duyck.

8) Missing return value initialization for IPV6_MINHOPCOUNT socket
   option handling.  From Hannes Frederic.

9) Fix regression in tasklet handling in jme/ksz884x/xilinx drivers,
   from Xiaotian Feng.

10) At smsc911x driver init time, we don't know if the chip is in word
    swap mode or not.  However we do need to wait for the control
    register's ready bit to be set before we program any other part of
    the chip.  Adjust the wait loop to account for this.  From
    Kamlakant Patel.

11) Revert erroneous MDIO bus unregister change to mdio-bitbang.c

12) Fix memory leak in /proc/net/sctp/, from Tommi Rantala.

13) tilegx driver registers IRQ with NULL name, oops, from Simon
    Marchi.

14) TCP metrics hash table kzalloc() based allocation can fail, back
    down to using vmalloc() if it does.  From Eric Dumazet.

15) Fix packet steering out-of-order delivery regression, from Tom
    Herbert.

Please pull, thanks a lot!

The following changes since commit 77b67063bb6bce6d475e910d3b886a606d0d=
91f7:

  Linux 3.7-rc5 (2012-11-11 13:44:33 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to a8203d3ccd7796675739aaa50f708a047601eed2=
:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel=
/git/linville/wireless (2012-11-16 14:37:18 -0500)

----------------------------------------------------------------

Alexander Duyck (2):
      vxlan: Fix error that was resulting in VXLAN MTU size being 10 by=
tes too large
      vxlan: Update hard_header_len based on lowerdev when instantiatin=
g VXLAN

Andrew Vagin (1):
      tcp: fix retransmission in repair mode

Antonio Quartulli (4):
      batman-adv: fix tt_global_entries flags update
      batman-adv: correctly pass the client flag on tt_response
      batman-adv: don't add TEMP clients belonging to other backbone no=
des
      batman-adv: process broadcast packets in BLA earlier

Arik Nemtsov (1):
      mac80211: sync acccess to tx_filtered/ps_tx_buf queues

Bj=F8rn Mork (1):
      net: cdc_ncm: add Huawei devices

David S. Miller (3):
      Revert "drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister b=
efore mdiobus_free"
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

David Spinadel (1):
      mac80211: init sched_scan_ies

Eric Dumazet (2):
      tcp: tcp_replace_ts_recent() should not be called from tcp_valida=
te_incoming()
      tcp: handle tcp_net_metrics_init() order-5 memory allocation fail=
ures

=46elix Fietkau (2):
      mac80211: do not call ieee80211_configure_filter if no interfaces=
 are up
      mac80211: call skb_dequeue/ieee80211_free_txskb instead of __skb_=
queue_purge

Hannes Frederic Sowa (1):
      ipv6: setsockopt(IPIPPROTO_IPV6, IPV6_MINHOPCOUNT) forgot to set =
return value

Hauke Mehrtens (1):
      brcmfmac: fix typo in CONFIG_BRCMISCAN

Jiri Pirko (1):
      net: correct check in dev_addr_del()

Johan Hedberg (2):
      Bluetooth: Fix having bogus entries in mgmt_read_index_list reply
      Bluetooth: Fix memory leak when removing a UUID

Johannes Berg (5):
      iwlwifi: handle DMA mapping failures
      iwlwifi: use ieee80211_free_txskb
      mac80211: fix memory leak in device registration error path
      mac80211: don't send null data packet when not associated
      wireless: allow 40 MHz on world roaming channels 12/13

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Kamlakant Patel (1):
      net/smsc911x: Fix ready check in cases where WORD_SWAP is needed

Kirill Smelkov (1):
      doc/net: Fix typo in netdev-features.txt

Marcel Holtmann (1):
      Bluetooth: Notify about device registration before power on

Marcos Chaparro (1):
      Bluetooth: ath3k: Add support for VAIO VPCEH [0489:e027]

Paulo S=E9rgio (1):
      Bluetooth: Fix error status when pairing fails

Rami Rosen (1):
      vxlan: fix a typo.

Saurabh Mohan (1):
      ipv4/ip_vti.c: VTI fix post-decryption forwarding

Simon Marchi (1):
      tilegx: request_irq with a non-null device name

Stefan Raspl (1):
      qeth: Fix IPA_CMD_QIPASSIST return code handling

Steve Glendinning (1):
      smsc95xx: set MII_BUSY bit to read/write PHY regs

Tom Herbert (1):
      net-rps: Fix brokeness causing OOO packets

Tommi Rantala (1):
      sctp: fix /proc/net/sctp/ memory leak

Ursula Braun (1):
      qeth: set new mac even if old mac is gone

Xi Wang (1):
      ipv4: avoid undefined behavior in do_ip_setsockopt()

Xiaotian Feng (1):
      drivers/net: fix tasklet misuse issue

 Documentation/networking/netdev-features.txt          |  2 +-
 drivers/bluetooth/ath3k.c                             |  1 +
 drivers/bluetooth/btusb.c                             |  1 +
 drivers/net/ethernet/jme.c                            | 28 ++++++++---=
-----------------
 drivers/net/ethernet/micrel/ksz884x.c                 | 16 ++++-------=
-----
 drivers/net/ethernet/smsc/smsc911x.c                  | 17 +++++++++++=
++++--
 drivers/net/ethernet/tile/tilegx.c                    |  2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c     | 12 ++++++-----=
-
 drivers/net/phy/mdio-bitbang.c                        |  1 -
 drivers/net/usb/cdc_ncm.c                             | 22 +++++++++++=
+++++++----
 drivers/net/usb/smsc95xx.c                            |  4 ++--
 drivers/net/vxlan.c                                   | 10 +++++++---
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c           |  2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c               |  2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c                | 23 +++++++++++=
++++++++++--
 drivers/s390/net/qeth_core_main.c                     | 24 +++++++++++=
+++++++++++--
 drivers/s390/net/qeth_l2_main.c                       | 13 ++++++++---=
--
 net/batman-adv/soft-interface.c                       | 12 ++++++-----=
-
 net/batman-adv/translation-table.c                    | 15 +++++++++++=
+++-
 net/bluetooth/hci_core.c                              |  4 ++--
 net/bluetooth/mgmt.c                                  | 12 +++++++----=
-
 net/bluetooth/smp.c                                   |  2 +-
 net/core/dev.c                                        |  4 +++-
 net/core/dev_addr_lists.c                             |  3 ++-
 net/ipv4/ip_sockglue.c                                | 35 +++++++++++=
+++++++++++-------------
 net/ipv4/ip_vti.c                                     |  5 +++++
 net/ipv4/tcp.c                                        |  4 ++--
 net/ipv4/tcp_input.c                                  | 15 ++++++++++-=
----
 net/ipv4/tcp_metrics.c                                | 12 +++++++++--=
-
 net/ipv4/tcp_output.c                                 |  4 ++++
 net/ipv6/ipv6_sockglue.c                              |  1 +
 net/mac80211/cfg.c                                    |  3 +++
 net/mac80211/ieee80211_i.h                            |  2 ++
 net/mac80211/main.c                                   |  6 ++++--
 net/mac80211/scan.c                                   |  2 +-
 net/mac80211/sta_info.c                               | 11 ++++++++---
 net/mac80211/status.c                                 |  9 +++++++++
 net/mac80211/tx.c                                     |  9 ++++++---
 net/mac80211/util.c                                   |  2 ++
 net/sctp/proc.c                                       |  8 ++++----
 net/wireless/reg.c                                    |  5 ++---
 42 files changed, 247 insertions(+), 120 deletions(-)
