From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net 4/4] bond: track sum of rx_unhandled for all slaves
Date: Wed, 27 Jan 2016 15:21:38 -0500
Message-ID: <1453926098-40181-5-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453926098-40181-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sample output with this set applied for an active-backup bond:

$ cat /proc/net/dev
Inter-|   Receive                                                       |  Transmit
 face |bytes    packets errs drop  unh fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  p6p1:   16024     238    0    0    0    0     0          0       521        0       0    0    0    0     0       0          0
  p7p1: 1691386   16537    0    0 16568    0     0          0       488        0       0    0    0    0     0       0          0
  p7p2: 1709438   16718    0    0    0    0     0          0       561        0       0    0    0    0     0       0          0
 bond0: 6183056   63065    0    0 33151    0     0          0     13964    24747     193    0    0    0     0       0          0
  p4p1:       0       0    0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
  p4p2:       0       0    0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
    lo:    4928      50    0    0    0    0     0          0         0     4928      50    0    0    0     0       0          0
  p5p1: 2259498   23401    0    0    0    0     0          0      6740    24747     193    0    0    0     0       0          0
  p5p2: 2232172   23127    0    0 16583    0     0          0      6736        0       0    0    0    0     0       0          0
   em4: 2347251   18224    0    0    0    0     0          0        90     4541      47    0    0    0     0       0          0
   em2: 1590296   16061    0    0    0    0     0          0        81        0       0    0    0    0     0       0          0
   em1: 1590180   16060    0    0    0    0     0          0        79        0       0    0    0    0     0       0          0
   em3: 2343156   18209    0    0    0    0     0          0        94        0       0    0    0    0     0       0          0
   ib0:       0       0    0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
$ cat /sys/devices/virtual/net/bond0/statistics/rx_unhandled
33181

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b5605..72164dc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3309,6 +3309,7 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
 		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
 		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
+		stats->rx_unhandled += sstats->rx_unhandled - pstats->rx_unhandled;
 
 		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
 		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
-- 
1.8.3.1
