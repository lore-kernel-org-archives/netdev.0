From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 04 Oct 2011 13:28:09 -0400 (EDT)
Message-ID: <20111004.132809.1879261914401460692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932788Ab1JDR2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 13:28:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) ipv6 accepted sockets forget to clear out ipv6_ac_list and ipv6_fl_list
   causing crashes later.  Fix from Zheng Yan.

2) RDSRDMA refcounting is busted, resulting in leaks and crashes on module
   unload.  Fix from Jonathan Lallinger.

3) Because of bugs in error code propagation, ibmveth gets OOPS when
   request_irq() fails.  Fix from Brian King.

4) Due to missing state checks, workqueues can get queued up after a bond
   is shutdown, crashing us on unload.  Fix from Andy Gospodarek.

5) Fix off-by-one corrupter in CAN BCM, from Oliver Hartkopp.

6) When link is brought down, pch_gbe can hang in NAPI poll or disable
   HW interrupts forever.  Fix from Toshiharu Okada.

7) When socket state overflow changes were added, this broke AF_PACKET
   statistic reporting in the non-ring case.  Fix from Willem de Bruijn.

8) PTP classifier incorrectly interprets general messages as event messages.
   Fix from Richard Cochran.

9) XEN netback driver was broken by the commit that converted it to
   hw_features.  TX was never restarted correctly after a VM restore/migrate.
   Fix from David Vrabel.

10) EEH recovery doesn't work in cxgb4 driver on PPC, need to set ->needs_freset.
    Fix from Divy Le Ray.

Please pull, thanks a lot!

The following changes since commit 9b13776977d45505469edc6decc93e9e3799afe2:

  Merge branch 'for-linus' of git://git.infradead.org/users/sameo/mfd-2.6 (2011-10-02 19:23:44 -0700)

are available in the git repository at:

  git://github.com/davem330/net.git master

Andy Gospodarek (1):
      bonding: properly stop queuing work when requested

Brian King (1):
      ibmveth: Fix oops on request_irq failure

David Vrabel (1):
      net: xen-netback: correctly restart Tx after a VM restore/migrate

Divy Le Ray (1):
      cxgb4: Fix EEH on IBM P7IOC

Ian Campbell (1):
      MAINTAINERS: tehuti: Alexander Indenbaum's address bounces

Jonathan Lallinger (1):
      RDSRDMA: Fix cleanup of rds_iw_mr_pool

Oliver Hartkopp (2):
      can bcm: fix tx_setup off-by-one errors
      can bcm: fix incomplete tx_setup fix

Richard Cochran (2):
      ptp: fix L2 event message recognition
      dp83640: reduce driver noise

Roy.Li (1):
      net: Documentation: Fix type of variables

Toshiharu Okada (2):
      pch_gbe: Fixed the issue on which PC was frozen when link was downed.
      pch_gbe: Fixed the issue on which a network freezes

Willem de Bruijn (1):
      make PACKET_STATISTICS getsockopt report consistently between ring and non-ring

Yan, Zheng (1):
      ipv6: nullify ipv6_ac_list and ipv6_fl_list when creating new socket

 Documentation/networking/ip-sysctl.txt |    4 +-
 MAINTAINERS                            |    1 -
 drivers/net/bonding/bond_3ad.c         |    3 +-
 drivers/net/bonding/bond_alb.c         |    3 +-
 drivers/net/bonding/bond_main.c        |   13 ++++---
 drivers/net/cxgb4/cxgb4_main.c         |    3 ++
 drivers/net/ibmveth.c                  |    4 +-
 drivers/net/pch_gbe/pch_gbe_main.c     |   56 +++++++++++++++----------------
 drivers/net/phy/dp83640.c              |    4 +-
 drivers/net/xen-netback/interface.c    |    4 +-
 include/linux/ptp_classify.h           |   13 ++++++--
 net/can/bcm.c                          |   53 +++++++++++++----------------
 net/ipv6/tcp_ipv6.c                    |    3 ++
 net/packet/af_packet.c                 |    5 ++-
 net/rds/iw_rdma.c                      |   13 +++++--
 15 files changed, 100 insertions(+), 82 deletions(-)
