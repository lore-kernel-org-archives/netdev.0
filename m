From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 01 Jan 2012 18:42:34 -0500 (EST)
Message-ID: <20120101.184234.350480175566737629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) mlx4 driver stops working after a ring size change due to forgotten
   clear of the queue vector value, fix from Yevgeny Petrilin.

2) RX multicast filter in skge is not restored after resume, breaking
   ipv6 amongst other things, fix from Florian Zumbiehl.

3) Fix sync message handling in IPVS, from Julian Anastasov.

4) ctnetlink timeout sanity checks never work due to signedness,
   fix from Xi Wang.

Please pull, thanks a lot!

The following changes since commit c7f46b7aa4ae5cbef32eb5e016512a14f936affa:

  Merge branch 'fix/asoc' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound (2011-12-31 11:55:06 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Florian Zumbiehl (1):
      skge: restore rx multicast filter on resume and after config changes

Julian Anastasov (1):
      ipvs: try also real server with port 0 in backup server

Xi Wang (1):
      netfilter: ctnetlink: fix timeout calculation

Yevgeny Petrilin (1):
      mlx4_en: nullify cq->vector field when closing completion queue

 drivers/net/ethernet/marvell/skge.c        |    3 +++
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |    1 +
 include/net/ip_vs.h                        |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c            |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c             |   10 ++++++++--
 net/netfilter/ipvs/ip_vs_sync.c            |    2 +-
 net/netfilter/nf_conntrack_netlink.c       |    4 ++--
 7 files changed, 17 insertions(+), 7 deletions(-)
