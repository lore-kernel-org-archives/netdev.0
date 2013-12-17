From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 Dec 2013 17:29:13 -0500 (EST)
Message-ID: <20131217.172913.872882830371558349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A quick batch of fixes, including the annoying bad lock stack
problem introduced by udp_sk_rx_dst_set() locking change:

1) Use xchg() instead of sk_dst_lock() in udp_sk_rx_dst_set(), from
   Eric Dumazet.

2) qlcnic bug fixes from Himanshu Madhani and Manish Chopra.

3) Update IPSEC MAINTAINERS entry, from Steffen Klassert.

4) Administrative neigh entry changes should generate netlink
   notifications the same as event generated ones.  From Bob
   Gilligan.

5) Netfilter SYNPROXY fixes from Patrick McHardy.

6) Netfilter nft_reject endianness fixes from Eric Leblond.

Please pull, thanks a lot!

The following changes since commit 319e2e3f63c348a9b66db4667efa73178e18b17d:

  Linux 3.13-rc4 (2013-12-15 12:31:33 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 781069279f049508274db63bfb352e8583e5c977:

  Merge branch 'fixes-for-3.13' of git://gitorious.org/linux-can/linux-can (2013-12-17 17:21:30 -0500)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      can: ems_usb: fix urb leaks on failure paths

Bob Gilligan (1):
      neigh: Netlink notification for administrative NUD state change

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'qlcnic'
      Merge branch 'fixes-for-3.13' of git://gitorious.org/linux-can/linux-can

Eric Dumazet (1):
      udp: ipv4: do not use sk_dst_lock from softirq context

Eric Leblond (1):
      netfilter: nft_reject: fix endianness in dump function

Hannes Frederic Sowa (1):
      ipv4: improve documentation of ip_no_pmtu_disc

Himanshu Madhani (4):
      qlcnic: Fix usage of netif_tx_{wake, stop} api during link change.
      qlcnic: Fix diagnostic test for all adapters.
      qlcnic: Fix TSS/RSS ring validation logic.
      qlcnic: Fix TSS/RSS validation for 83xx/84xx series adapter.

Jason Wang (1):
      netvsc: don't flush peers notifying work during setting mtu

Manish Chopra (2):
      qlcnic: Fix memory allocation
      qlcnic: Allow firmware dump collection when auto firmware recovery is disabled

Manish chopra (2):
      qlcnic: Fix mailbox processing during diagnostic test
      qlcnic: Dump mailbox registers when mailbox command times out.

Marc Kleine-Budde (1):
      can: peak_usb: fix mem leak in pcan_usb_pro_init()

Patrick McHardy (1):
      netfilter: SYNPROXY target: restrict to INPUT/FORWARD

Sasha Levin (1):
      net: unix: allow bind to fail on mutex lock

Steffen Klassert (1):
      MAINTAINERS: Update the IPsec maintainer entry

Wei Yongjun (1):
      xen-netback: fix fragments error handling in checksum_setup_ip()

wangweidong (1):
      sctp: loading sctp when load sctp_probe

 Documentation/networking/ip-sysctl.txt                |  8 +++++--
 MAINTAINERS                                           | 11 +++++++++-
 drivers/net/can/usb/ems_usb.c                         |  3 ++-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c           |  3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   | 47 ++++++++++++++++++----------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h   |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 65 ++++++++++++++++++++++++++++++++++---------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c   | 19 +++++++---------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        | 10 ++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  2 +-
 drivers/net/hyperv/netvsc_drv.c                       |  1 -
 drivers/net/xen-netback/netback.c                     |  3 +++
 net/core/neighbour.c                                  |  1 +
 net/ipv4/netfilter/ipt_SYNPROXY.c                     |  1 +
 net/ipv4/netfilter/nft_reject_ipv4.c                  |  2 +-
 net/ipv4/udp.c                                        | 13 ++++-------
 net/ipv6/netfilter/ip6t_SYNPROXY.c                    |  1 +
 net/sctp/probe.c                                      | 17 ++++++++++++++-
 net/unix/af_unix.c                                    |  8 +++++--
 19 files changed, 127 insertions(+), 89 deletions(-)
