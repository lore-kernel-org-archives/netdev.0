From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 05 Mar 2012 17:15:32 -0500 (EST)
Message-ID: <20120305.171532.1094926884019491898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) TCP SACK processing can calculate an incorrect reordering value in
   some cases, fix from Neal Cardwell.

2) tcp_mark_head_lost() can split SKBs in situations where it should
   not, violating send queue invariants expected by other pieces of
   code and thus resulting (eventually) in corrupted retransmit state
   counters.  Also from Neal Cardwell.

3) qla3xxx erroneously calls spin_lock_irqrestore() with constant
   hw_flags of zero.  Fix from Santosh Nayak.

4) Fix NULL deref in rt2x00, from Gabor Juhos.

5) pch_gbe passes address of wrong typed object to pch_gbe_validate_opt=
ion
   thus corrupting part of the value.  From Dan Carpenter.

6) We must check the return value of nlmsg_parse() before trying to use
   the results.  From Eric Dumazet.

7) Bridging code fails to check return value of ipv6_dev_get_saddr() th=
us
   potentially leaving uninitialized garbage in the outgoing ipv6 heade=
r.
   From Ulrich Weber.

8) Due to rounding and a reversed operation on jiffies, bridge message
   ages can go backwards instead of forwards, thus breaking STP.  Fixes
   from Joakim Tjernlund.

9) r8169 modifies Config* registers without properly holding the
   Config9346 lock, resulting in corrupted IP fragments on some chips.
   Fix from Francois Romieu.

10) NET_PACKET_ENGINE default wan't set properly during the network
    driver mega-move.  Fix from Stephen Hemminger.

11) vmxnet3 uses TCP header size where it actually should use the UDP
    header size, fix from Shreyas Bhatewara.

12) Netfilter bridge module autoload is busted in the compat case, fix =
from
    Florian Westphal.

13) Wireless Key removal was not setting multicast bits correctly thus
    accidently killing the unicast key 0 and thus all traffic stops.
    Fix from Johannes Berg.

14) Fix endless retries of A-MPDU transmissions in brcm80211 driver.

Please pull, thanks a lot!

The following changes since commit 550cf00dbc8ee402bef71628cb71246493dd=
4500:

  Merge tag 'mmc-fixes-for-3.3' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/cjb/mmc (2012-03-05 08:51:10 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Arend van Spriel (2):
      brcm80211: smac: fix endless retry of A-MPDU transmissions
      brcm80211: smac: only print block-ack timeout message at trace le=
vel

Dan Carpenter (2):
      pch_gbe: memory corruption calling pch_gbe_validate_option()
      enic: fix an endian bug in enic_probe()

David S. Miller (1):
      Merge branch 'master' of git://1984.lsi.us.es/net

Eric Dumazet (1):
      rtnetlink: fix rtnl_calcit() and rtnl_dump_ifinfo()

=46elix Fietkau (1):
      ath9k_hw: prevent writes to const data on AR9160

=46lorian Westphal (1):
      netfilter: bridge: fix module autoload in compat case

Gabor Juhos (1):
      rt2x00: fix a possible NULL pointer dereference

Joakim Tjernlund (2):
      bridge: Adjust min age inc for HZ > 256
      bridge: message age needs to increase, not decrease.

Johannes Berg (1):
      iwlwifi: fix key removal

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Matt Carlson (1):
      tg3: Fix tg3_get_stats64 for 5700 / 5701 devs

Mohammed Shafi Shajakhan (2):
      mac80211: zero initialize count field in ieee80211_tx_rate
      mac80211: Fix a warning on changing to monitor mode from STA

Neal Cardwell (3):
      tcp: fix comment for tp->highest_sack
      tcp: fix false reordering signal in tcp_shifted_skb
      tcp: don't fragment SACKed skbs in tcp_mark_head_lost()

Santosh Nayak (1):
      qla3xxx: ethernet: Fix bogus interrupt state flag.

Shreyas Bhatewara (1):
      vmxnet3: Fix transport header size

Ulrich Weber (1):
      bridge: check return value of ipv6_dev_get_saddr()

fran=E7ois romieu (1):
      r8169: corrupted IP fragments fix for large mtu.

stephen hemminger (1):
      packetengines: fix config default

 drivers/net/ethernet/broadcom/tg3.c                |   45 ++++++++++--=
--------
 drivers/net/ethernet/cisco/enic/enic.h             |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |   15 ++++---
 drivers/net/ethernet/packetengines/Kconfig         |    1 +
 drivers/net/ethernet/qlogic/qla3xxx.c              |    5 +-
 drivers/net/ethernet/realtek/r8169.c               |    8 ++++
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    7 +---
 drivers/net/vmxnet3/vmxnet3_int.h                  |    4 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   25 +----------
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   19 ++++++++
 drivers/net/wireless/ath/ath9k/hw.h                |    1 -
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |   12 ++----
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |   10 ++++-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    3 +-
 include/linux/tcp.h                                |    3 +-
 include/net/tcp.h                                  |    5 +-
 net/bridge/br_multicast.c                          |    7 ++-
 net/bridge/br_stp.c                                |    6 +-
 net/bridge/netfilter/ebtables.c                    |   10 +----
 net/core/rtnetlink.c                               |   18 ++++----
 net/ipv4/tcp_input.c                               |   19 +++++----
 net/mac80211/iface.c                               |    3 +
 net/mac80211/rate.c                                |    2 +-
 24 files changed, 122 insertions(+), 110 deletions(-)
