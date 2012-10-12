From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Oct 2012 15:25:22 -0400 (EDT)
Message-ID: <20121012.152522.712436180774349943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Alexey Kuznetsov noticed we routed TCP resets improperly in the
   assymetric routing case, fix this by reverting a change that
   made us use the incoming interface in the outgoing route key
   when we didn't have a socket context to work with.

2) TCP sysctl kernel memory leakage to userspace fix from Alan Cox.

3) Move UAPI bits from David Howells, WIMAX and CAN this time.

4) Fix TX stalls in e1000e wrt. Byte Queue Limits, from Hiroaki SHIMODA,
   Denys Fedoryshchenko, and Jesse Brandeburg.

5) Fix IPV6 crashes in packet generator module, from Amerigo Wang.

6) Tidies and fixes in the new VXLAN driver from Stephen Hemminger.

7) Bridge IP options parse doesn't check first if SKB header has
   at least an IP header's worth of content present.  Fix from	
   Sarveshwar Bandi.

8) The kernel now generates compound pages on transmit and the Xen
   netback drivers needs some adjustments in order to handle this.
   Fix from Ian Campbell.

9) Turn off ASPM in JME driver, from Kevin Bardon and Matthew Garrett.

Please pull, thanks a lot!

The following changes since commit 2474542f64432398f503373f53bdf620491bcfa8:

  Merge tag 'for-3.7-rc1' of git://gitorious.org/linux-pwm/linux-pwm (2012-10-10 20:15:24 +0900)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to dabdaf0caa3af520dbc1df87b2fb4e77224037bd:

  mcs7830: Fix link state detection (2012-10-12 13:56:52 -0400)

----------------------------------------------------------------
Alan Cox (2):
      kaweth: print correct debug ptr
      tcp: sysctl interface leaks 16 bytes of kernel memory

Alexey Kuznetsov (1):
      tcp: resets are misrouted

Amerigo Wang (7):
      pktgen: fix crash when generating IPv6 packets
      pktgen: set different default min_pkt_size for different protocols
      pktgen: display IPv4 address in human-readable format
      pktgen: enable automatic IPv6 address setting
      pktgen: replace scan_ip6() with in6_pton()
      net: add doc for in6_pton()
      net: add doc for in4_pton()

Amitkumar Karwar (3):
      mwifiex: reset scan_processing flag in failure cases
      mwifiex: update cfg80211 with correct reason code when association fails
      mwifiex: update cfg80211 with correct reason code when connection is lost

Bing Zhao (1):
      mwifiex: return -EBUSY if scan request cannot be honored

Dan Carpenter (1):
      isdn: fix a wrapping bug in isdn_ppp_ioctl()

Daniel Golle (1):
      rt2x00/rt3352: Fix lnagain assignment to use register 66.

David Howells (2):
      UAPI: (Scripted) Disintegrate include/linux/wimax
      UAPI: (Scripted) Disintegrate include/linux/can

David S. Miller (3):
      Merge tag 'master-2012-10-08' of git://git.kernel.org/.../linville/wireless
      Merge branch 'uapi-for-3.7' of git://gitorious.org/linux-can/linux-can
      Merge tag 'disintegrate-wimax-20121009' of git://git.infradead.org/users/dhowells/linux-headers

Felix Fietkau (4):
      ath9k: fix ASPM initialization on resume
      ath9k: improve suspend/resume reliability
      ath9k: use ieee80211_free_txskb
      mac80211: use ieee80211_free_txskb to fix possible skb leaks

Hiroaki SHIMODA (1):
      e1000e: Change wthresh to 1 to avoid possible Tx stalls

Ian Campbell (1):
      xen: netback: handle compound page fragments on transmit.

Jean-Christian de Rivaz (1):
      Add CDC-ACM support for the CX93010-2x UCMxx USB Modem

Kevin Baradon (1):
      net/ethernet/jme: disable ASPM

Mark Brown (1):
      of/mdio: Staticise !CONFIG_OF stubs

Oliver Neukum (1):
      usbnet: Support devices reporting idleness

Ondrej Zary (1):
      mcs7830: Fix link state detection

Ronald Wahl (1):
      carl9170: fix sleep in softirq context

Sarveshwar Bandi (1):
      bridge: Pull ip header into skb->data before looking into ip header.

Thomas Pedersen (1):
      mac80211: call drv_get_tsf() in sleepable context

Wei Yongjun (1):
      ath5k: fix potential NULL pointer dereference in ath5k_beacon_update()

stephen hemminger (10):
      vxlan: minor output refactoring
      vxlan: fix byte order in hash function
      vxlan: use ip_route_output
      vxlan: associate with tunnel socket on transmit
      vxlan: allow configuring port range
      vxlan: add additional headroom
      vxlan: fix receive checksum handling
      vxlan: fix oops when give unknown ifindex
      ipv4: fix route mark sparse warning
      vti: fix sparse bit endian warnings

 drivers/isdn/i4l/isdn_ppp.c                  |   2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h    |   6 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c   |   2 +-
 drivers/net/ethernet/jme.c                   |   4 +++
 drivers/net/usb/cdc_eem.c                    |   4 +++
 drivers/net/usb/kaweth.c                     |   2 +-
 drivers/net/usb/mcs7830.c                    |  30 ++++++++++++------
 drivers/net/usb/usbnet.c                     |  17 +++++++++++
 drivers/net/vxlan.c                          | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/wireless/ath/ath5k/base.c        |   3 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |   2 +-
 drivers/net/wireless/ath/ath9k/hw.c          |   5 +++
 drivers/net/wireless/ath/ath9k/hw.h          |   1 +
 drivers/net/wireless/ath/ath9k/main.c        |  15 +++------
 drivers/net/wireless/ath/ath9k/pci.c         |   7 +++++
 drivers/net/wireless/ath/ath9k/xmit.c        |  53 +++++++++++++++++---------------
 drivers/net/wireless/ath/carl9170/carl9170.h |   1 +
 drivers/net/wireless/ath/carl9170/main.c     |  29 +++++++++---------
 drivers/net/wireless/mwifiex/cfg80211.c      |  27 +++++++++++++----
 drivers/net/wireless/mwifiex/join.c          |   6 ++--
 drivers/net/wireless/mwifiex/main.h          |   2 +-
 drivers/net/wireless/mwifiex/scan.c          |  38 ++++++++++++-----------
 drivers/net/wireless/mwifiex/sta_cmdresp.c   |   4 +--
 drivers/net/wireless/mwifiex/sta_event.c     |  31 ++++++++++++-------
 drivers/net/wireless/rt2x00/rt2800lib.c      |   4 +--
 drivers/net/xen-netback/netback.c            |  40 +++++++++++++++++++++---
 drivers/usb/class/cdc-acm.c                  |   3 ++
 include/linux/can/Kbuild                     |   5 ---
 include/linux/if_link.h                      |   6 ++++
 include/linux/of_mdio.h                      |  20 ++++++------
 include/linux/usb/usbnet.h                   |   2 ++
 include/linux/wimax/Kbuild                   |   1 -
 include/uapi/linux/can/Kbuild                |   5 +++
 include/{ => uapi}/linux/can/bcm.h           |   0
 include/{ => uapi}/linux/can/error.h         |   0
 include/{ => uapi}/linux/can/gw.h            |   0
 include/{ => uapi}/linux/can/netlink.h       |   0
 include/{ => uapi}/linux/can/raw.h           |   0
 include/uapi/linux/wimax/Kbuild              |   1 +
 include/{ => uapi}/linux/wimax/i2400m.h      |   0
 net/bridge/br_netfilter.c                    |   3 ++
 net/core/pktgen.c                            | 146 ++++++++++++++++++---------------------------------------------------------------------
 net/core/utils.c                             |  24 +++++++++++++++
 net/ipv4/ip_vti.c                            |   4 +--
 net/ipv4/route.c                             |   2 +-
 net/ipv4/sysctl_net_ipv4.c                   |   2 ++
 net/ipv4/tcp_ipv4.c                          |   7 +++--
 net/ipv6/tcp_ipv6.c                          |   3 +-
 net/mac80211/mesh_sync.c                     |   3 +-
 net/mac80211/status.c                        |   4 +--
 net/mac80211/tx.c                            |  22 ++++++++------
 51 files changed, 450 insertions(+), 296 deletions(-)
 rename include/{ => uapi}/linux/can/bcm.h (100%)
 rename include/{ => uapi}/linux/can/error.h (100%)
 rename include/{ => uapi}/linux/can/gw.h (100%)
 rename include/{ => uapi}/linux/can/netlink.h (100%)
 rename include/{ => uapi}/linux/can/raw.h (100%)
 rename include/{ => uapi}/linux/wimax/i2400m.h (100%)
