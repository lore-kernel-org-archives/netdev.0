From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 13 Apr 2010 04:43:37 -0700 (PDT)
Message-ID: <20100413.044337.95338578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Of note is the fix for the wireless regression reported last week, a
fix for virtio net crashes with DEBUG_SG enabled, and some minor bug
cures in other drivers.

I tried to cure a loopback TCP checksumming anomaly with dataless
packets, but couldn't get it right the first time so reverted.

It's a harmless issue (we check checksums of ACKs over loopback) and
we've had it forever, but such things should be toyed with in our
-next trees not here...

I merged in your tree to resolve some conflicts mentioned by
Stephen Rothwell.

1) Restrict WoL in igb driver to devices which can support it.
   From Stefan Assmann.

2) Add missing sg_init_table to virtio_net, from Shirley Ma.

3) e1000e can walk past the end of TX ring links when we get
   lots of interrupts, fix from Terry Loftin.

4) iwlwifi bug fixes, including the fix for the crash reported
   last week.  From Shanyu Zhao, Wey-Yi Guy, and Zhu Yi.

5) Fix RCU checking warning in mac80211, from Johannes Berg.

6) Bridging code IGMP3 report parser accesses entry pointer
   incorrectly.  Fix from Herbert Xu.

7) stmmac miscalculates resource size by hand, use resource_size()
   and get it right, from Dan Carpenter.

8) X.25 protocol can access past end of SKB, fix from John Hughes.

Please pull, thanks a lot!

The following changes since commit 0eddb519b9127c73d53db4bf3ec1d45b13f844d1:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../roland/infiniband

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (1):
      qlcnic: fix set mac addr

Brice Goglin (1):
      myri10ge: fix rx_pause in myri10ge_set_pauseparam

Dan Carpenter (1):
      stmmac: use resource_size()

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'vhost' of git://git.kernel.org/.../mst/vhost
      tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Revert "tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb"
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Eric Dumazet (1):
      can: avoids a false warning

Felix Fietkau (1):
      ath9k: fix double calls to ath_radio_enable

Florian Fainelli (1):
      r6040: fix r6040_multicast_list

Herbert Xu (1):
      bridge: Fix IGMP3 report parsing

Javier Cardona (1):
      mac80211: Handle mesh action frames in ieee80211_rx_h_action

Jeff Dike (1):
      vhost-net: fix vq_memory_access_ok error checking

Johannes Berg (1):
      mac80211: annotate station rcu dereferences

John Hughes (2):
      x25: Patch to fix bug 15678 - x25 accesses fields beyond end of packet.
      x.25 attempts to negotiate invalid throughput

Jorge Boncompte [DTI2] (1):
      udp: fix for unicast RX path optimization

Ken Kawasaki (1):
      smc91c92_cs: define multicast_table as unsigned char

Michael Chan (1):
      cnic: Fix crash during bnx2x MTU change.

Patrick Loschmidt (1):
      net: corrected documentation for hardware time stamping

Shanyu Zhao (1):
      iwlwifi: use consistent table for tx data collect

Shirley Ma (1):
      virtio_net: missing sg_init_table

Stefan Assmann (1):
      igb: restrict WoL for 82576 ET2 Quad Port Server Adapter

Terry Loftin (1):
      e1000e: stop cleaning when we reach tx_ring->next_to_use

Wey-Yi Guy (1):
      iwlwifi: need check for valid qos packet before free

Zhu Yi (2):
      iwlwifi: fix DMA allocation warnings
      iwlwifi: avoid Tx queue memory allocation in interface down

 Documentation/networking/timestamping.txt |   76 ++++++++++++--------
 drivers/net/cnic.c                        |   10 ++--
 drivers/net/e1000e/netdev.c               |    2 +
 drivers/net/igb/igb_ethtool.c             |    1 +
 drivers/net/igb/igb_main.c                |    1 +
 drivers/net/myri10ge/myri10ge.c           |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c          |   13 ++--
 drivers/net/qlcnic/qlcnic_hw.c            |    3 +
 drivers/net/r6040.c                       |   11 +--
 drivers/net/stmmac/stmmac_main.c          |   10 ++--
 drivers/net/virtio_net.c                  |    2 +
 drivers/net/wireless/ath/ath9k/main.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c   |   13 +++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |   55 +++++++--------
 drivers/net/wireless/iwlwifi/iwl-core.c   |   11 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h   |    5 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c     |  107 +++++++++++++++++++++++++----
 drivers/vhost/vhost.c                     |    4 +
 include/net/x25.h                         |    4 +
 net/bridge/br_multicast.c                 |    2 +-
 net/can/raw.c                             |    2 +-
 net/ipv4/udp.c                            |    4 +-
 net/ipv6/udp.c                            |    4 +-
 net/mac80211/main.c                       |    4 +-
 net/mac80211/mesh.c                       |    3 -
 net/mac80211/rx.c                         |    5 ++
 net/mac80211/sta_info.c                   |   20 ++++-
 net/x25/af_x25.c                          |   67 +++++++++++++++++--
 net/x25/x25_facilities.c                  |   27 ++++++-
 net/x25/x25_in.c                          |   15 +++-
 30 files changed, 348 insertions(+), 138 deletions(-)
