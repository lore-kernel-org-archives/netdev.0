From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 23 Aug 2013 00:45:58 -0700 (PDT)
Message-ID: <20130823.004558.1878374702787369530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Revert Johannes Berg's genetlink locking fix, because it causes
   regressions.

   Johannes and Pravin Shelar are working on fixing things properly.


2) Do not drop ipv6 ICMP messages without a redirected
   header option, they are legal.  From Duan Jiong.

3) Missing error return propagation in probing of via-ircc
   driver.  From Alexey Khoroshilov.

4) Do not clear out broadcast/multicast/unicast/WOL bits
   in r8169 when initializing, from Peter Wu.

5) realtek phy driver programs wrong interrupt status bit,
   from Giuseppe CAVALLARO.

6) Fix statistics regression in AF_PACKET code, from Willem de Bruijn.

7) Bridge code uses wrong bitmap length, from Toshiaki Makita.

8) SFC driver uses wrong indexes to look up MAC filters, from Ben
   Hutchings.

9) Don't pass stack buffers into usb control operations in hso driver,
   from Daniel Gimpelevich.

10) Multiple ipv6 fragmentation headers in one packet is illegal and
    such packets should be dropped, from Hannes Frederic Sowa.

11) When TCP sockets are "repaired" as part of checkpoint/restart, the
    timestamp field of SKBs need to be refreshed otherwise RTOs can
    be wildly off.  From Andrey Vagin.

12) Fix memcpy args (uses 'address of pointer' instead of 'pointer')
    in hostp driver.  From Dan Carpenter.

13) nl80211hdr_put() doesn't return an ERR_PTR, but some code believes
    it does.  From Dan Carpenter.

14) Fix regression in wireless SME disconnects, from Johannes Berg.

15) Don't use a stack buffer for DMA in zd1201 USB wireless driver,
    from Jussi Kivilinna.

Please pull, thanks a lot!

The following changes since commit fd3930f70c8d14008f3377d51ce039806dfc=
542e:

  proc: more readdir conversion bug-fixes (2013-08-19 16:26:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 4a5a8aa6c966eafc106543bd955ae388230420e5=
:

  ipv4: expose IPV4_DEVCONF (2013-08-22 20:30:15 -0700)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      via-ircc: don't return zero if via_ircc_open() failed

Andrey Vagin (1):
      tcp: set timestamps for restored skb-s

Ariel Elior (2):
      bnx2x: Protect against VFs' ndos when SR-IOV is disabled
      bnx2x: set VF DMAE when first function has 0 supported VFs

Ben Hutchings (1):
      sfc: Fix lookup of default RX MAC filters when steered using etht=
ool

Dan Carpenter (2):
      Hostap: copying wrong data prism2_ioctl_giwaplist()
      nl80211: nl80211hdr_put() doesn't return an ERR_PTR

Daniel Gimpelevich (2):
      hso: Earlier catch of error condition
      hso: Fix stack corruption on some architectures

David S. Miller (3):
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'sfc-3.11' of git://git.kernel.org/.../bwh/sfc

Dmitry Kravkov (3):
      bnx2x: dropless flow control not always functional
      bnx2x: Change DCB context handling
      bnx2x: Consider DCBX remote error

Duan Jiong (1):
      ipv6: handle Redirect ICMP Message with no Redirected Header opti=
on

Emmanuel Grumbach (1):
      iwlwifi: pcie: disable L1 Active after pci_enable_device

Giuseppe CAVALLARO (1):
      net: phy: rtl8211: fix interrupt on status link change

Guy Cohen (1):
      Revert "iwlwifi: pcie: clear RFKILL interrupt in AMPG"

Hannes Frederic Sowa (2):
      ipv6: remove max_addresses check from ipv6_create_tempaddr
      ipv6: drop packets with multiple fragmentation headers

Johannes Berg (3):
      iwlwifi: mvm: disconnect if time event scheduling fails
      cfg80211: don't request disconnect if not connected
      Revert "genetlink: fix family dump race"

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jussi Kivilinna (1):
      zd1201: do not use stack as URB transfer_buffer

Linus L=FCssing (1):
      batman-adv: check return type of unicast packet preparations

Peter Wu (1):
      r8169: remember WOL preferences on driver load

Sathya Perla (1):
      be2net: fix disabling TX in be_close()

Stanislaw Gruszka (1):
      iwlwifi: dvm: fix calling ieee80211_chswitch_done() with NULL

Toshiaki Makita (1):
      bridge: Use the correct bit length for bitmap functions in the VL=
AN code

Vlad Yasevich (3):
      macvtap: simplify usage of tap_features
      macvtap: Correctly set tap features when IFF_VNET_HDR is disabled=
=2E
      macvtap: Ignore tap features when VNET_HDR is off

Willem de Bruijn (1):
      packet: restore packet statistics tp_packets to include drops

Yuval Mintz (1):
      bnx2x: prevent VF benign attentions

stephen hemminger (1):
      ipv4: expose IPV4_DEVCONF

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c   | 49 +++++++++++++++=
+++++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h   |  3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 45 +++++++++++++++=
+++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 56 +++++++++++++++=
++++++++++++++++++-----------------------
 drivers/net/ethernet/emulex/benet/be_main.c       |  2 +-
 drivers/net/ethernet/realtek/r8169.c              |  2 +-
 drivers/net/ethernet/sfc/filter.c                 |  2 +-
 drivers/net/irda/via-ircc.c                       |  6 ++----
 drivers/net/macvtap.c                             | 18 +++++++++------=
---
 drivers/net/phy/realtek.c                         |  4 ++--
 drivers/net/usb/hso.c                             | 15 ++++++++++-----
 drivers/net/wireless/hostap/hostap_ioctl.c        |  4 ++--
 drivers/net/wireless/iwlwifi/dvm/mac80211.c       |  5 ++++-
 drivers/net/wireless/iwlwifi/iwl-prph.h           |  2 --
 drivers/net/wireless/iwlwifi/mvm/time-event.c     | 33 +++++++++++++++=
++++++++----------
 drivers/net/wireless/iwlwifi/pcie/rx.c            |  8 --------
 drivers/net/wireless/iwlwifi/pcie/trans.c         | 10 +++++-----
 drivers/net/wireless/zd1201.c                     |  4 +++-
 include/linux/inetdevice.h                        | 34 +--------------=
-------------------
 include/linux/ipv6.h                              |  1 +
 include/net/ip6_route.h                           |  2 ++
 include/uapi/linux/ip.h                           | 34 +++++++++++++++=
+++++++++++++++++++
 net/batman-adv/unicast.c                          | 10 +++++++---
 net/bridge/br_fdb.c                               | 10 +++++-----
 net/bridge/br_netlink.c                           |  4 ++--
 net/bridge/br_vlan.c                              |  4 ++--
 net/ipv4/tcp.c                                    |  7 +++++++
 net/ipv6/addrconf.c                               | 10 ++++------
 net/ipv6/ndisc.c                                  |  4 +++-
 net/ipv6/reassembly.c                             |  5 +++++
 net/ipv6/route.c                                  | 21 +++++++++++++++=
++++++
 net/netlink/genetlink.c                           |  7 -------
 net/packet/af_packet.c                            |  2 ++
 net/wireless/nl80211.c                            | 22 +++++++++++----=
-------
 net/wireless/sme.c                                | 10 ++++------
 36 files changed, 282 insertions(+), 175 deletions(-)
