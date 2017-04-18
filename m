From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 18 Apr 2017 16:23:13 -0400 (EDT)
Message-ID: <20170418.162313.1554593582235878572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) BPF tail call handling bug fixes from Daniel Borkmann.

2) Fix allowance of too many rx queues in sfc driver, from Bert
   Kenward.

3) Non-loopback ipv6 packets claiming src of ::1 should be dropped,
   from Florian Westphal.

4) Statistics requests on KSZ9031 can crash, fix from Grygorii
   Strashko.

5) TX ring handling fixes in mediatek driver, from Sean Wang.

6) ip_ra_control can deadlock, fix lock acquisition ordering to
   fix, from Cong WANG.

7) Fix use after free in ip_recv_error(), from Willem de Buijn.

Please pull, thanks a lot!

The following changes since commit 1bf4b1268e66d9364fc6fd41f906bc01458530ac:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input (2017-04-14 17:51:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to acf167f3f2495f0b6565f6e8ac9bd87158a0e98d:

  Merge branch 'bpf-fixes' (2017-04-17 15:51:58 -0400)

----------------------------------------------------------------
Bert Kenward (1):
      sfc: limit the number of receive queues

Daniel Borkmann (2):
      bpf: fix cb access in socket filter programs on tail calls
      bpf: fix checking xdp_adjust_head on tail calls

David Ahern (1):
      net: vrf: Fix setting NLM_F_EXCL flag when adding l3mdev rule

David S. Miller (2):
      Merge branch 'mediatek-tx-bugs'
      Merge branch 'bpf-fixes'

Florian Westphal (1):
      ipv6: drop non loopback packets claiming to originate from ::1

George Cherian (1):
      net: thunderx: Fix set_max_bgx_per_node for 81xx rgx

Grygorii Strashko (1):
      net: phy: micrel: fix crash when statistic requested for KSZ9031 phy

Sean Wang (2):
      net: ethernet: mediatek: fix inconsistency between TXD and the used buffer
      net: ethernet: mediatek: fix inconsistency of port number carried in TXD

WANG Cong (1):
      ipv4: fix a deadlock in ip_ra_control

Willem de Bruijn (1):
      net-timestamp: avoid use-after-free in ip_recv_error

 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |  1 +
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  1 +
 drivers/net/ethernet/mediatek/mtk_eth_soc.c       | 31 +++++++++++++++++--------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h       | 12 +++++++++---
 drivers/net/ethernet/sfc/efx.c                    |  7 +++++++
 drivers/net/ethernet/sfc/falcon/efx.c             |  7 +++++++
 drivers/net/phy/micrel.c                          | 17 ++---------------
 drivers/net/vrf.c                                 |  2 +-
 kernel/bpf/syscall.c                              |  8 ++++++++
 net/core/skbuff.c                                 |  1 +
 net/ipv4/ip_sockglue.c                            | 10 +++++-----
 net/ipv4/ipmr.c                                   | 11 ++---------
 net/ipv4/raw.c                                    |  2 ++
 net/ipv6/datagram.c                               | 10 +---------
 net/ipv6/ip6_input.c                              |  7 +++++--
 15 files changed, 69 insertions(+), 58 deletions(-)
