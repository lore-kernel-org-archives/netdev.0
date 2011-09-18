From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 18 Sep 2011 02:21:25 -0400 (EDT)
Message-ID: <20110918.022125.1554085675403900813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I thought the kernel.org issue would be cleared up a lot sooner than
it appears it will end up being resolved, so I held off on creating
another GIT tree to push changes to you until just a day or two ago.

Anyways, here are all of the fixes which have queued up meanwhile.

As usual, the majority of the stuff is in the drivers, with only a few
protocol and generic networking fixes here and there.

1) Fix DMA mapping failures and checksum offload failure handling in
   ibmveth driver, from Anton Blanchard and Brian King.

2) Netfilter fixes:
   a) Fix xt_rateest_mt_checkentry() error handling, from Eric Dumazet.
   b) Fix leak in ipq_build_packet_message(), from Jesper Juhl.
   c) Build dependencies for ebtables are wrong, from Bart De Schuymer.
   d) Userspace should never be allowed to send NF_STOLEN verdicts to
      nf_queue, fix from Florian Westphal.
   e) Fix translation of peer's call-id field in nf_ct_pptp when
      both the server and client are NATed, from Sanket Shah.
   f) Fix handling of invalid TCP options in nf_ct_tcp, from Jozsef Kad=
lecsik.
   g) Fix TCP option lengh calculations in nf_ct_tcp's tcp_sack(), also
      from Jozsef.

3) Socket address hardening in inet_bind() broke some apps, loosen
   the checks so they work again.

4) Fix locking in mac80211's __sta_info_destroy() from Johannes Berg.

5) Fix crash when unplugging ath9k devices, from Mohammed Shafi Shajakh=
an.

6) Fix stack corruption and command queue timeouts in iwlagn, from Joha=
nnes
   Berg.

7) Fix resets while reading device config, eliminate accidental accesse=
s of
   not-present registers, and fix coalescing bug in bnx2x driver from D=
mitry Kravkov,
   Vladislav Zolotarov, and Ariel Elior.

8) cls_rsvp.h indexes attribute array off-by-one, fix from Igor Maravi=E6=
=2E

9) Syn flooding messages fill people's logs, rate limit it and report t=
he
   number of times it is detected in a statistic.  From Eric Dumazet.

10) CAN protocol layer needs to use del_time_sync(), from Rajan Aggarwa=
l.

11) Flow cache accidently uses entries from one namespace in another, f=
ix
    from David Ward.

12) If zero copy skbs hit forward path, we must copy them, from Michael=
 S. Tsirkin.

13) ether_setup() needs to "OR" in the IFF_TX_SKB_SHARING bit so that o=
ther
    settings made already don't get lost, from Neil Horman.

14) Revert regression causing SFC write-combining change, from Ben Hutc=
hings.

15) Cure FIFO overrun handling in pch_gbe driver, from Toshiharu Okada.

16) SCTP connection wedges when it sees two COOKIE_ECHO chunks, fix fro=
m
    Max Matveev.

17) Fix NULL deref in CAIF stack, from Eric Dumazet.

18) Fix ipv4 route metrics leak caused by kfree_rcu() conversions, fix
    from Zheng Yan.

19) flow_key_compare has dependencies upon flow key alignment, make sur=
e
    they are met.  From David Ward.

20) Also from David Ward, compare flow keys correctly based upon their
    address-family specific size.  Otherwise we reference garbage.

21) Fix ti_hecc driver build, missing include, from Daniel Mack.

22) Don't use inetpeer for the metrics of anything other than host
    routes, from Zheng Yan.

23) Fix EEPROM signature handling of e1000 devices on HPPA.  From
    Jeff Kirsher.

24) ipv6's datagram_send_ctl() needs to adhere to the socket's
    ->transparent setting, fix from Maciej =AFenczykowski.

Please pull, thanks a lot!

The following changes since commit 9e79e3e9dd9672b37ac9412e9a9267143065=
51fe:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2011=
-08-30 11:28:18 -0700)

are available in the git repository at:

  git://github.com/davem330/net.git master

Andi Kleen (1):
      IRDA: Fix global type conflicts in net/irda/irsysctl.c v2

Anton Blanchard (3):
      ibmveth: Fix issue with DMA mapping failure
      ibmveth: Checksum offload is always disabled
      ibmveth: Fix checksum offload failure handling

Ariel Elior (1):
      bnx2x: Fix for a host coalescing bug which impared latency.

Bart De Schuymer (1):
      netfilter: ebtables: fix ebtables build dependency

Ben Hutchings (2):
      Revert "sfc: Use write-combining to reduce TX latency" and follow=
-ups
      sfc: Use 64-bit writes for TX push where possible

Brian King (1):
      ibmveth: Fix DMA unmap error

Daniel Mack (1):
      can: ti_hecc: include linux/io.h

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'for-davem' of git://git.infradead.org/users/linvill=
e/wireless
      Merge branch 'master' of ../netdev/

David Ward (1):
      net: Align AF-specific flowi structs to long

Dmitry Kravkov (6):
      bnx2x: fix BRB thresholds for dropless_fc mode
      bnx2x: decrease print level to debug
      bnx2x: fix MF for 4-port devices
      bnx2x: don't reset device while reading its configuration.
      bnx2x: init fw_seq after undi_unload is done
      bnx2x: don't access removed registers on 57712 and above

Eric Dumazet (4):
      netfilter: xt_rateest: fix xt_rateest_mt_checkentry()
      net: ipv4: relax AF_INET check in bind()
      tcp: Change possible SYN flooding messages
      caif: fix a potential NULL dereference

=46elix Fietkau (1):
      ath9k_hw: fix calibration on 5 ghz

=46lorian Westphal (1):
      netfilter: nf_queue: reject NF_STOLEN verdicts from userspace

George (2):
      rtlwifi: rtl8192su: Fix problem connecting to HT-enabled AP
      rtlwifi: Fix problem when switching connections

Ian Campbell (3):
      MAINTAINERS: Update ATLX driver maintainers
      MAINTAINERS: Update Cisco VIC driver maintainers
      MAINTAINERS: Update BNA 10G Maintainer

Igor Maravi=E6 (1):
      pkt_sched: cls_rsvp.h was outdated

Jeff Kirsher (1):
      e1000: Fix driver to be used on PA RISC C8000 workstations

Jesper Juhl (1):
      netfilter: ip_queue: Fix small leak in ipq_build_packet_message()

Johannes Berg (3):
      mac80211: fix missing sta_lock in __sta_info_destroy
      iwlagn: fix stack corruption
      iwlagn: fix command queue timeout

John W. Linville (1):
      Merge branch 'master' of git://git.infradead.org/users/linville/w=
ireless into for-davem

Jozsef Kadlecsik (2):
      netfilter: nf_ct_tcp: fix incorrect handling of invalid TCP optio=
n
      netfilter: nf_ct_tcp: wrong multiplication of TCPOLEN_TSTAMP_ALIG=
NED in tcp_sack skips fastpath

Kavan Smith (1):
      ipheth: iPhone 4 Verizon CDMA USB Product ID add

Maciej =AFenczykowski (1):
      net: relax PKTINFO non local ipv6 udp xmit check

Marcos Paulo de Souza (1):
      Documentation: networking: dmfe.txt: Remove the maintainer of orp=
han networking driver

Max Matveev (1):
      sctp: deal with multiple COOKIE_ECHO chunks

Michael S. Tsirkin (1):
      net: copy userspace buffers on device forwarding

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic on unplugging the device

Patrick McHardy (1):
      netfilter: update netfilter git URL

Rajkumar Manoharan (1):
      ath9k_hw: Fix init mode register regression

Sanket Shah (1):
      netfilter: nf_ct_pptp: fix DNATed PPTP connection address transla=
tion

Stanislaw Gruszka (1):
      iwlegacy: fix BUG_ON(info->control.rates[0].idx < 0)

Toshiharu Okada (3):
      pch_gbe: fixed the issue which receives an unnecessary packet.
      pch_gbe: added the process of FIFO over run error
      pch_gbe: support ML7831 IOH

Vladislav Zolotarov (1):
      bnx2x: fix rx ring size report

Yan, Zheng (2):
      ipv4: Fix fib_info->fib_metrics leak
      ipv6: don't use inetpeer to store metrics for routes.

Yaniv Rosner (6):
      bnx2x: Fix ETS bandwidth
      bnx2x: Enable FEC for 57810-KR
      bnx2x: Remove fiber remote fault detection
      bnx2x: Fix XMAC loopback test
      bnx2x: Fix 578xx link LED
      bnx2x: Fix ethtool advertisement

dpward (2):
      net: Make flow cache namespace-aware
      net: Handle different key sizes between address families in flow =
cache

nhorman (1):
      net: don't clear IFF_XMIT_DST_RELEASE in ether_setup

rajan.aggarwal85@gmail.com (1):
      net/can/af_can.c: Change del_timer to del_timer_sync

 Documentation/networking/dmfe.txt                |    3 +-
 MAINTAINERS                                      |    6 +-
 drivers/net/Kconfig                              |   11 +-
 drivers/net/bnx2x/bnx2x.h                        |  124 +++++++---
 drivers/net/bnx2x/bnx2x_cmn.c                    |   27 +-
 drivers/net/bnx2x/bnx2x_ethtool.c                |   48 +++-
 drivers/net/bnx2x/bnx2x_link.c                   |   46 ++--
 drivers/net/bnx2x/bnx2x_main.c                   |  162 ++++++++----
 drivers/net/bnx2x/bnx2x_reg.h                    |    7 +-
 drivers/net/bnx2x/bnx2x_stats.c                  |    7 +-
 drivers/net/can/ti_hecc.c                        |    1 +
 drivers/net/e1000/e1000_hw.c                     |    6 +
 drivers/net/ibmveth.c                            |   48 +++--
 drivers/net/pch_gbe/pch_gbe.h                    |   12 +-
 drivers/net/pch_gbe/pch_gbe_main.c               |  302 ++++++++++++++=
--------
 drivers/net/sfc/efx.c                            |   18 +--
 drivers/net/sfc/io.h                             |    6 -
 drivers/net/sfc/mcdi.c                           |   46 ++--
 drivers/net/sfc/nic.c                            |    7 -
 drivers/net/sfc/nic.h                            |    2 -
 drivers/net/sfc/siena.c                          |   25 +--
 drivers/net/sfc/workarounds.h                    |    2 -
 drivers/net/usb/ipheth.c                         |    5 +
 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c      |    2 +-
 drivers/net/wireless/ath/ath9k/main.c            |    6 +
 drivers/net/wireless/iwlegacy/iwl-3945-rs.c      |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c |    2 +
 drivers/net/wireless/rtlwifi/core.c              |    8 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c     |   11 +-
 include/linux/skbuff.h                           |    1 +
 include/linux/snmp.h                             |    2 +
 include/net/flow.h                               |   25 ++-
 include/net/request_sock.h                       |    3 +-
 include/net/sctp/command.h                       |    1 +
 include/net/tcp.h                                |    3 +
 include/net/transp_v6.h                          |    1 +
 net/bridge/netfilter/Kconfig                     |    2 +-
 net/caif/caif_dev.c                              |    6 +-
 net/can/af_can.c                                 |    2 +-
 net/core/dev.c                                   |    8 +
 net/core/flow.c                                  |   36 ++-
 net/core/skbuff.c                                |   22 ++-
 net/ethernet/eth.c                               |    2 +-
 net/ipv4/af_inet.c                               |    7 +-
 net/ipv4/fib_semantics.c                         |   10 +-
 net/ipv4/netfilter/ip_queue.c                    |   12 +-
 net/ipv4/proc.c                                  |    2 +
 net/ipv4/tcp_ipv4.c                              |   51 ++--
 net/ipv6/datagram.c                              |    5 +-
 net/ipv6/ip6_flowlabel.c                         |    8 +-
 net/ipv6/ipv6_sockglue.c                         |    2 +-
 net/ipv6/netfilter/ip6_queue.c                   |   12 +-
 net/ipv6/raw.c                                   |    4 +-
 net/ipv6/route.c                                 |   33 ++-
 net/ipv6/tcp_ipv6.c                              |   31 +--
 net/ipv6/udp.c                                   |    4 +-
 net/irda/irsysctl.c                              |    6 +-
 net/irda/qos.c                                   |    6 +-
 net/mac80211/sta_info.c                          |    2 +-
 net/netfilter/nf_conntrack_pptp.c                |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c           |    6 +-
 net/netfilter/nfnetlink_queue.c                  |    4 +-
 net/netfilter/xt_rateest.c                       |    9 +-
 net/sched/cls_rsvp.h                             |   27 +-
 net/sctp/sm_sideeffect.c                         |    5 +
 net/sctp/sm_statefuns.c                          |    6 +
 68 files changed, 827 insertions(+), 508 deletions(-)
