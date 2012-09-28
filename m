From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 28 Sep 2012 03:31:03 -0400 (EDT)
Message-ID: <20120928.033103.2004263257973473206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The most important bit here is the netfilter fix:

1) Netfilter xt_limit module can use uninitialized rules, from
   Jan Engelhardt.

2) Wei Yongjun has found several more spots where error pointers
   were treated as NULL/non-NULL and vice versa.

3) bnx2x was converted to pci_io{,un}map() but one remaining plain
   iounmap() got missed.  From Neil Horman.

4) Due to a fence-post type error in initialization of inetpeer
   entries (which is where we store the ICMP rate limiting
   information), we can erroneously drop ICMPs if the inetpeer
   was created right around when jiffies wraps.

   Fix from Nicolas Dichtel.

5) smsc75xx resume fix from Steve Glendinnig.

6) LAN87xx smsc chips need an explicit hardware init, from Marek
   Vasut.

7) qlcnic uses msleep() with locks held, fix from Narendra K.

Please pull, thanks a lot.

The following changes since commit 5e19997a742c7c8203be628a7a69babc3bcf01a4:

  Merge tag 'for-linus' of git://linux-c6x.org/git/projects/linux-c6x-upstreaming (2012-09-26 14:28:17 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to df555b665367f9de6c04826acc482096f17c243d:

  netdev: octeon: fix return value check in octeon_mgmt_init_phy() (2012-09-28 01:18:32 -0400)

----------------------------------------------------------------
David S. Miller (1):
      Merge branch 'master' of git://1984.lsi.us.es/nf

Jan Engelhardt (1):
      netfilter: xt_limit: have r->cost != 0 case work

Marek Vasut (1):
      net: phy: smsc: Implement PHY config_init for LAN87xx

Narendra K (1):
      qlcnic: Fix scheduling while atomic bug

Neil Horman (1):
      bnx2: Clean up remaining iounmap

Nicolas Dichtel (1):
      inetpeer: fix token initialization

Steve Glendinning (1):
      smsc75xx: fix resume after device reset

Wei Yongjun (4):
      l2tp: fix return value check
      team: fix return value check
      netdev: pasemi: fix return value check in pasemi_mac_phy_init()
      netdev: octeon: fix return value check in octeon_mgmt_init_phy()

 drivers/net/ethernet/broadcom/bnx2.c            |  2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c       |  4 +---
 drivers/net/ethernet/pasemi/pasemi_mac.c        |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |  4 ++--
 drivers/net/phy/smsc.c                          | 28 +++++++++++++++++++++++++++-
 drivers/net/team/team.c                         | 12 ++++++------
 drivers/net/usb/smsc75xx.c                      |  1 +
 net/ipv4/inetpeer.c                             |  5 ++++-
 net/l2tp/l2tp_netlink.c                         | 12 ++++++------
 net/netfilter/xt_limit.c                        |  8 ++++----
 10 files changed, 54 insertions(+), 26 deletions(-)
