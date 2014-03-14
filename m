From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 00/10] Small fixes for Tx time
	stamping in Intel drivers
Date: Fri, 14 Mar 2014 18:34:31 +0100
Message-ID: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This series is mostly about fixing two things:
 - when user space request both SW and HW time stamps
   only one of them should be generated (SW is fallback
   to HW). Intel drivers would report two time stamps
   per packet which may be confusing to user space app;
 - all(?) Intel drivers have one set of PTP TX registers
   per NIC so drivers with multiple TX rings need some
   kind of mutual exclusion otherwise they will leak skbs
These apply to igb, ixgbe and i40e.

Apart from that I added timeout for time stamp checking
in e1000e and removed 'if' clause that cannot be triggered.

NOTE: I do not own any igb or i40e devices. Patches 7-10
      were only compile-tested!

Also I think that there is a race between time stamp
polling work and calling i40e_ptp_tx_hwtstamp() directly
from interrupt in i40e, but as I said I don't have any
device to test that.

	-- Jakub Kicinski


Jakub Kicinski (10):
  doc: update driver TX algorithm in timestamping.txt
  e1000e: add timeout for TX HW time stamping work
  e1000e: remove redundant if clause from PTP work
  ixgbe: remove redundant if clause from PTP work
  ixgbe: never generate both software and hardware timestamps
  ixgbe: fix race conditions on queuing skb for HW time stamp
  igb: never generate both software and hardware timestamps
  igb: fix race conditions on queuing skb for HW time stamp
  i40e: never generate both software and hardware timestamps
  i40e: fix race conditions on queuing skb for HW time stamp

 Documentation/networking/timestamping.txt     |  6 +++---
 drivers/net/ethernet/intel/e1000e/e1000.h     |  2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c   |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c    | 10 +++++++---
 drivers/net/ethernet/intel/i40e/i40e.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c    |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  7 ++++---
 drivers/net/ethernet/intel/igb/igb.h          |  3 ++-
 drivers/net/ethernet/intel/igb/igb_main.c     |  7 ++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c      |  3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  8 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  |  7 +++----
 13 files changed, 39 insertions(+), 20 deletions(-)

-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
