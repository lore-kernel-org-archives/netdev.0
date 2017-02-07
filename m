From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 07 Feb 2017 14:42:03 -0500 (EST)
Message-ID: <20170207.144203.182609571712833095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Load correct firmware in rtl8192ce wireless driver, from Jurij
   Smakov.

2) Fix leak of tx_ring and tx_cq due to overwriting in mlx4 driver,
   from Martin KaFai Lau.

3) Need to reference count PHY driver module when it is attached, from
   Mao Wenan.

4) Don't do zero length vzalloc() in ethtool register dump, from
   Stanislaw Gruszka.

5) Defer net_disable_timestamp() to a workqueue to get out of locking
   issues, from Eric Dumazet.

6) We cannot drop the SKB dst when IP options refer to them, fix also
   from Eric Dumazet.

7) Incorrect packet header offset calculations in ip6_gre, again from
   Eric Dumazet.

8) Missing tcp_v6_restore_cb() causes use-after-free, from Eric too.

9) tcp_splice_read() can get into an infinite loop with URG, and hey
   it's from Eric once more.

10) vnet_hdr_sz can change asynchronously, so read it once during
    decision making in macvtap and tun, from Willem de Bruijn.

11) Can't use kernel stack for DMA transfers in USB networking
    drivers, from Ben Hutchings.

12) Handle csum errors properly in UDP by calling the proper
    destructor, from Eric Dumazet.

13) For non-deterministic softirq run when scheduling NAPI from
    a workqueue in mlx4, from Benjamin Poirier.

Please pull, thanks a lot!

The following changes since commit 6d04dfc8966019b8b0977b2cb942351f13d2b178:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-02-01 11:52:27 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 912964eacb111551db73429719eb5fadcab0ff8a:

  sctp: check af before verify address in sctp_addr_id2transport (2017-02-07 14:07:23 -0500)

----------------------------------------------------------------
Arnd Bergmann (1):
      hns: avoid stack overflow with CONFIG_KASAN

Ben Hutchings (4):
      pegasus: Use heap buffers for all register access
      rtl8150: Use heap buffers for all register access
      catc: Combine failure cleanup code in catc_probe()
      catc: Use heap buffer for memory size test

Benjamin Poirier (1):
      mlx4: Invoke softirqs after napi_reschedule

David Lebrun (1):
      ipv6: sr: remove cleanup flag and fix HMAC computation

David S. Miller (5):
      Merge branch 'mlx4-queue-reinit'
      Merge tag 'mac80211-for-davem-2017-02-06' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'wireless-drivers-for-davem-2017-02-06' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'read-vnet_hdr_sz-once'
      Merge branch 'net-Fix-on-stack-USB-buffers'

Eric Dumazet (7):
      net: use a work queue to defer net_disable_timestamp() work
      ipv4: keep skb->dst around in presence of IP options
      netlabel: out of bound access in cipso_v4_validate()
      ip6_gre: fix ip6gre_err() invalid reads
      ipv6: tcp: add a missing tcp_v6_restore_cb()
      tcp: avoid infinite loop in tcp_splice_read()
      udp: properly cope with csum errors

Jouni Malinen (2):
      mac80211: Fix FILS AEAD protection in Association Request frame
      mac80211: Allocate a sync skcipher explicitly for FILS AEAD

Jurij Smakov (1):
      rtlwifi: rtl8192ce: Fix loading of incorrect firmware

Linus Lüssing (1):
      ipv6: Fix IPv6 packet loss in scenarios involving roaming + snooping switches

Mao Wenan (1):
      net: phy: Fix lack of reference count on PHY driver

Marcelo Ricardo Leitner (1):
      sctp: avoid BUG_ON on sctp_wait_for_sndbuf

Martin KaFai Lau (2):
      mlx4: Fix memory leak after mlx4_en_update_priv()
      mlx4: xdp_prog becomes inactive after ethtool '-L' or '-G'

Masashi Honma (1):
      nl80211: Fix mesh HT operation check

Stanislaw Gruszka (1):
      ethtool: do not vzalloc(0) on registers dump

Thorsten Horstmann (1):
      mac80211: Fix adding of mesh vendor IEs

Willem de Bruijn (2):
      tun: read vnet_hdr_sz once
      macvtap: read vnet_hdr_size once

Xin Long (1):
      sctp: check af before verify address in sctp_addr_id2transport

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h   |  8 ++------
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c     |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c      | 35 +++++++++++++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c          |  5 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h        |  3 ++-
 drivers/net/macvtap.c                               |  4 ++--
 drivers/net/phy/phy_device.c                        |  7 +++++++
 drivers/net/tun.c                                   | 10 ++++++----
 drivers/net/usb/catc.c                              | 56 ++++++++++++++++++++++++++++++++++----------------------
 drivers/net/usb/pegasus.c                           | 29 +++++++++++++++++++++++++----
 drivers/net/usb/rtl8150.c                           | 34 +++++++++++++++++++++++++++-------
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c |  9 +++++++--
 include/net/cipso_ipv4.h                            |  4 ++++
 include/net/sock.h                                  |  4 +++-
 include/uapi/linux/seg6.h                           |  9 +++------
 net/core/datagram.c                                 |  8 ++++++--
 net/core/dev.c                                      | 31 +++++++++++++------------------
 net/core/ethtool.c                                  |  9 ++++++---
 net/ipv4/cipso_ipv4.c                               |  4 ++++
 net/ipv4/ip_sockglue.c                              |  9 ++++++++-
 net/ipv4/tcp.c                                      |  6 ++++++
 net/ipv4/udp.c                                      |  2 +-
 net/ipv6/addrconf.c                                 | 10 ++++++++--
 net/ipv6/exthdrs.c                                  | 31 +++----------------------------
 net/ipv6/ip6_gre.c                                  | 40 +++++++++++++++++++++-------------------
 net/ipv6/seg6_hmac.c                                |  8 ++++----
 net/ipv6/tcp_ipv6.c                                 | 24 +++++++++++++-----------
 net/ipv6/udp.c                                      |  2 +-
 net/mac80211/fils_aead.c                            |  6 +++---
 net/mac80211/mesh.c                                 |  2 +-
 net/sctp/socket.c                                   |  5 +++--
 net/wireless/nl80211.c                              |  1 +
 32 files changed, 255 insertions(+), 164 deletions(-)
