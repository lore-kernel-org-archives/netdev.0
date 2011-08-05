From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 05 Aug 2011 04:20:43 -0700 (PDT)
Message-ID: <20110805.042043.1083078815291317666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The only serious regression that I know of which is still
pending is that forcedeth issue Ingo reported and I'm hoping
Jiri can resolve that quickly, otherwise we'll revert all the
VLAN changes as per Ingo's revert patch.

1) Fix sendmmsg() regressions, particularly wrt. certain LSMs which
   need to validate the sockaddr of every sendmsg call.  From
   Tetsuo Handa and Anton Blanchard.

2) Fix truncard ATM packets over br2864, from Chas Williams.

3) sfq_enqueue() corrupts queue state due to missing checks and
   call to qdisc_tree_decrease_qlen(), from Eric Dumazet.

4) Paul Moore contact info update.

5) Fix accidental TX restart during NIC unload in bnx2x driver, from
   Vladislav Zolotarov.

6) Fix setting MAC address on 8168e-vl chips, from Francois
   Romieu.

7) dst->neighbour accesses need RCU handling now, since these days
   we can change it on a live object, fix from Eric Dumazet.

8) Two MLX4 bug fixes from Yevgeny Petrilin based upon reports by
   Roland Dreier.

9) Fix lost "wrap" bit in TX ring of macb driver during TX underrun
   recovery, from Tord Andersson.

10) Fix endianness problems in cdc_ncm driver, from Giuseppe Scrivano.

11) IPV4 multicast code uses wrong variable to index array, from Julia
    Lawall.

12) Similar array indexing problem in NIU driver, also from Julia Lawal=
l.

13) Fix sunrpc kerneldoc warning, from Randy Dunlap.

14) Fix ->real_parent access race in proc connector, from Oleg Nesterov=
=2E

15) Add device ID for DLINK 530T rev C1 to R8169 driver, from Lennart
    Sorensen.

16) sis190 needs private ->ndo_set_mac_address handler so it can update
    it's RX filter properly.  From Klement Fish.

17) Fix key lengths for rfc3686(ctr(aes)) IPSEC algorithm entry, from
    Tushar Gohad.

18) IPVS needs to unregister notifier on module unload, from Hans
    Schillstrom and Simon Horman.

19) Fix off-by-one in nl80211_trigger_scan(), from Dan Carpenter.

20) Fix rtlwifi OOPS on ARM, from Larry Finger.

21) Fix accidental bzero() of 'skb' instead of skb data area in rt2x00
    driver, oops, fix from Stanislaw Gruszka.

22) Fix regression causing iwlagn to not set driver private properly,
    from Emmanuel Grumbach.

23) Do not use power save idle mode on iwl 5000 series chips, from
    Wey-Yi Guy.

24) Wake on Lan doesn't work on second port of i350 IGB devices, fix
    from Carolyn Wyborny.

25) Fix suspend/resume on ath9k when ASM is disabled, from Stanislaw
    Gruszka.

Please pull, thanks a lot!

The following changes since commit 140d0b2108faebc77c6523296e211e509cb9=
f5f9:

  Do 'shm_init_ns()' in an early pure_initcall (2011-08-04 19:35:59 -10=
00)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

Anton Blanchard (2):
      net: sendmmsg should only return an error if no messages were sen=
t
      net: Cap number of elements for sendmmsg

Bruce Allan (2):
      e1000e: remove unnecessary check for NULL pointer
      e1000e: minor re-order of #include files

Carolyn Wyborny (1):
      igb: fix WOL on second port of i350 device

Chas Williams (1):
      atm: br2864: sent packets truncated in VC routed mode

Dan Carpenter (1):
      cfg80211: off by one in nl80211_trigger_scan()

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../horms/ipvs-2.6
      MAINTAINERS: Remove Pekka Savola from ipv6.
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of master.kernel.org:/.../jkirsher/net

Don Skidmore (1):
      ixgbe: fix __ixgbe_notify_dca() bail out code

Emil Tantilov (1):
      ixgbe: fix PHY link setup for 82599

Emmanuel Grumbach (1):
      iwlagn: sysfs couldn't find the priv pointer

Eric Dumazet (3):
      sch_sfq: fix sfq_enqueue()
      net: add kerneldoc to skb_copy_bits()
      net: fix NULL dereferences in check_peer_redir()

=46elix Fietkau (1):
      ath9k: initialize tx chainmask before testing channel tx power va=
lues

Giuseppe Scrivano (1):
      cdc_ncm: fix endianness problem.

Helmut Schaa (1):
      rt2x00: Fix compilation without CONFIG_RT2X00_LIB_CRYPTO

Jesper Juhl (1):
      Documentation/bonding.txt: Update to 3.x version numbers

Jesse Brandeburg (1):
      intel drivers: repair missing flush operations

Joe Perches (1):
      MAINTAINERS: orphan FrameRelay DLCI

John W. Linville (1):
      Merge git://git.kernel.org/.../linville/wireless-next into for-da=
vem

Jon Mason (1):
      irda: use PCI_VENDOR_ID_*

Julia Lawall (2):
      net: adjust array index
      drivers/net/niu.c: adjust array index

Klement Fish (1):
      sis190: Rx filter init is needed for MAC address change.

Larry Finger (1):
      rtlwifi: Fix kernel oops on ARM SOC

Lennart Sorensen (1):
      r8169: Add support for D-Link 530T rev C1 (Kernel Bug 38862)

Max Matveev (1):
      ipv6: check for IPv4 mapped addresses when connecting IPv6 socket=
s

Oleg Nesterov (1):
      proc_fork_connector: a lockless ->real_parent usage is not safe

Paul Moore (2):
      doc: Update the MAINTAINERS info for Paul Moore
      doc: Update the email address for Paul Moore in various source fi=
les

Randy Dunlap (1):
      net: fix new sunrpc kernel-doc warning

Simon Horman (1):
      IPVS: Free resources on module removal

Stanislaw Gruszka (4):
      iwlegacy: set tx power after rxon_assoc
      ath9k: skip ->config_pci_powersave() if PCIe port has ASPM disabl=
ed
      rt2x00: rt2800: fix zeroing skb structure
      rt2x00: fix usage of NULL queue

Tetsuo Handa (1):
      net: Fix security_socket_sendmsg() bypass problem.

Tord Andersson (1):
      macb: restore wrap bit when performing underrun cleanup

Tushar Gohad (1):
      xfrm: Fix key lengths for rfc3686(ctr(aes))

Vladislav Zolotarov (1):
      bnx2x: Prevent restarting Tx during bnx2x_nic_unload

Wey-Yi Guy (1):
      iwlagn: 5000 do not support idle mode

Yaniv Rosner (10):
      bnx2x: Fix missing pause on for 578xx
      bnx2x: Fix chip hanging due to TX pipe stall.
      bnx2x: Fix remote fault handling
      bnx2x: Fix BCM578xx-B0 MDIO access
      bnx2x: Fix LED behavior
      bnx2x: Fix link issue with DAC over 578xx
      bnx2x: Fix BCM84833 link
      bnx2x: Fix BCM54618se invalid link indication
      bnx2x: Fix BCM578xx MAC test
      bnx2x: Clear MDIO access warning during first driver load

Yevgeny Petrilin (2):
      mlx4: Fixing Ethernet unicast packet steering
      mlx4: decreasing ref count when removing mac

fran=E7ois romieu (1):
      r8169 : MAC address change fix for the 8168e-vl.

 Documentation/networking/bonding.txt       |    2 +-
 MAINTAINERS                                |   10 +-
 drivers/connector/cn_proc.c                |    8 +-
 drivers/net/bnx2x/bnx2x_cmn.c              |   10 +-
 drivers/net/bnx2x/bnx2x_hsi.h              |    2 +
 drivers/net/bnx2x/bnx2x_link.c             |  218 +++++++++++++++++++-=
--------
 drivers/net/bnx2x/bnx2x_link.h             |    3 +-
 drivers/net/bnx2x/bnx2x_reg.h              |    6 +-
 drivers/net/e1000/e1000_ethtool.c          |    6 +
 drivers/net/e1000/e1000_hw.c               |    3 +
 drivers/net/e1000e/es2lan.c                |    2 +
 drivers/net/e1000e/ethtool.c               |   11 ++-
 drivers/net/e1000e/ich8lan.c               |    7 +-
 drivers/net/e1000e/lib.c                   |    1 +
 drivers/net/e1000e/netdev.c                |    2 +-
 drivers/net/e1000e/phy.c                   |    2 +
 drivers/net/igb/e1000_nvm.c                |    1 +
 drivers/net/igb/igb_ethtool.c              |    5 +
 drivers/net/igb/igb_main.c                 |    4 +-
 drivers/net/igbvf/netdev.c                 |    2 +
 drivers/net/irda/smsc-ircc2.c              |   18 +--
 drivers/net/ixgb/ixgb_ee.c                 |    9 +
 drivers/net/ixgb/ixgb_hw.c                 |    2 +
 drivers/net/ixgbe/ixgbe_82599.c            |    1 +
 drivers/net/ixgbe/ixgbe_common.c           |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c          |    5 +
 drivers/net/ixgbe/ixgbe_main.c             |    3 +-
 drivers/net/ixgbe/ixgbe_phy.c              |    3 +
 drivers/net/ixgbe/ixgbe_x540.c             |    1 +
 drivers/net/macb.c                         |    3 +
 drivers/net/mlx4/en_port.c                 |    2 +-
 drivers/net/mlx4/main.c                    |    2 +
 drivers/net/mlx4/port.c                    |    9 +-
 drivers/net/niu.c                          |    4 +-
 drivers/net/r8169.c                        |   28 ++++
 drivers/net/sis190.c                       |   12 ++-
 drivers/net/usb/cdc_ncm.c                  |  156 +++++++-------------
 drivers/net/wireless/ath/ath9k/ar9002_hw.c |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c |    6 +-
 drivers/net/wireless/ath/ath9k/hw.c        |   11 +-
 drivers/net/wireless/ath/ath9k/hw.h        |    3 +-
 drivers/net/wireless/ath/ath9k/init.c      |    2 +
 drivers/net/wireless/ath/ath9k/pci.c       |   27 ++++
 drivers/net/wireless/iwlegacy/iwl-3945.c   |    6 +-
 drivers/net/wireless/iwlegacy/iwl-4965.c   |    8 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c    |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.h    |    2 +
 drivers/net/wireless/iwlwifi/iwl-pci.c     |   18 +-
 drivers/net/wireless/iwlwifi/iwl-power.c   |    3 +-
 drivers/net/wireless/rt2x00/rt2800lib.c    |    3 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h    |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c    |    5 +-
 drivers/net/wireless/rtlwifi/pci.c         |   20 ++-
 include/net/cipso_ipv4.h                   |    2 +-
 include/net/dst.h                          |   17 ++-
 include/net/netlabel.h                     |    2 +-
 net/atm/br2684.c                           |    2 -
 net/core/skbuff.c                          |   17 ++-
 net/ipv4/igmp.c                            |    2 +-
 net/ipv4/ip_output.c                       |   10 +-
 net/ipv4/route.c                           |   14 +-
 net/ipv6/addrconf.c                        |    2 +-
 net/ipv6/datagram.c                        |   11 +-
 net/ipv6/ip6_fib.c                         |    2 +-
 net/ipv6/ip6_output.c                      |   13 ++-
 net/ipv6/route.c                           |   35 +++--
 net/netfilter/ipvs/ip_vs_ctl.c             |    1 +
 net/netlabel/Makefile                      |    2 -
 net/netlabel/netlabel_addrlist.c           |    2 +-
 net/netlabel/netlabel_addrlist.h           |    2 +-
 net/netlabel/netlabel_cipso_v4.c           |    2 +-
 net/netlabel/netlabel_cipso_v4.h           |    2 +-
 net/netlabel/netlabel_domainhash.c         |    2 +-
 net/netlabel/netlabel_domainhash.h         |    2 +-
 net/netlabel/netlabel_kapi.c               |    2 +-
 net/netlabel/netlabel_mgmt.c               |    2 +-
 net/netlabel/netlabel_mgmt.h               |    2 +-
 net/netlabel/netlabel_unlabeled.c          |    2 +-
 net/netlabel/netlabel_unlabeled.h          |    2 +-
 net/netlabel/netlabel_user.c               |    2 +-
 net/netlabel/netlabel_user.h               |    2 +-
 net/sched/sch_sfq.c                        |    7 +-
 net/socket.c                               |   73 +++++----
 net/sunrpc/xprt.c                          |    1 +
 net/wireless/nl80211.c                     |    2 +-
 net/xfrm/xfrm_algo.c                       |    4 +-
 security/selinux/hooks.c                   |    2 +-
 security/selinux/include/netif.h           |    2 +-
 security/selinux/include/netlabel.h        |    2 +-
 security/selinux/include/netnode.h         |    2 +-
 security/selinux/include/netport.h         |    2 +-
 security/selinux/netif.c                   |    2 +-
 security/selinux/netlabel.c                |    2 +-
 security/selinux/netnode.c                 |    2 +-
 security/selinux/netport.c                 |    2 +-
 security/selinux/selinuxfs.c               |    2 +-
 security/selinux/ss/ebitmap.c              |    2 +-
 security/selinux/ss/mls.c                  |    2 +-
 security/selinux/ss/mls.h                  |    2 +-
 security/selinux/ss/policydb.c             |    2 +-
 security/selinux/ss/services.c             |    2 +-
 security/smack/smack_lsm.c                 |    2 +-
 102 files changed, 615 insertions(+), 350 deletions(-)
