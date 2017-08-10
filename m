From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 10 Aug 2017 10:21:24 -0700 (PDT)
Message-ID: <20170810.102124.1969570284171219105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix handling of initial STATE message in TIPC, from Jon Paul
   Maloy.

2) Fix stats handling in bcm_sysport_get_stats(), from Florian
   Fainelli.

3) Reject 16777215 VNI value in geneve_validate(), from Girish
   Moodalbail.

4) Fix initial IGMP sysctl setting regression, from Nikolay Borisov.

5) Once a UFO fragmented frame is treated as UFO, we should continue
   doing so.  Likewise once a frame has been segmented, we should
   continue doing that and not try to convert it to a UFO frame.
   From Willem de Bruijn.

6) Test the AF_PACKET RX/TX ring pg_vec state under the socket lock
   to prevent races.  From Willem de Bruijn.

Please pull, thanks a lot!

The following changes since commit 48fb6f4db940e92cfb16cd878cddd59ea6120d06:

  futex: Remove unnecessary warning from get_futex_key (2017-08-09 14:00:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to c27927e372f0785f3303e8fad94b85945e2c97b7:

  packet: fix tp_reserve race in packet_set_ring (2017-08-10 09:52:12 -0700)

----------------------------------------------------------------
Florian Fainelli (1):
      net: systemport: Fix software statistics for SYSTEMPORT Lite

Girish Moodalbail (1):
      geneve: maximum value of VNI cannot be used

Jon Paul Maloy (1):
      tipc: remove premature ESTABLISH FSM event at link synchronization

Nikolay Borisov (1):
      igmp: Fix regression caused by igmp sysctl namespace code.

Willem de Bruijn (2):
      udp: consistently apply ufo or fragmentation
      packet: fix tp_reserve race in packet_set_ring

Xin Long (1):
      net: sched: set xt_tgchk_param par.nft_compat as 0 in ipt_init_target

 drivers/net/ethernet/broadcom/bcmsysport.c |  4 ++++
 drivers/net/geneve.c                       |  2 +-
 net/ipv4/af_inet.c                         |  7 +++++++
 net/ipv4/igmp.c                            |  6 ------
 net/ipv4/ip_output.c                       |  8 +++++---
 net/ipv4/udp.c                             |  2 +-
 net/ipv6/ip6_output.c                      |  7 ++++---
 net/packet/af_packet.c                     | 13 +++++++++----
 net/sched/act_ipt.c                        |  2 +-
 net/tipc/node.c                            |  4 +---
 10 files changed, 33 insertions(+), 22 deletions(-)
