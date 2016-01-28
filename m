From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v2 4/4] bond: track sum of rx_nohandler for all slaves
Date: Thu, 28 Jan 2016 10:49:48 -0500
Message-ID: <1453996188-29965-5-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453996188-29965-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453996188-29965-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sample output with this set applied for an active-backup bond:

$ cat /sys/devices/virtual/net/bond0/lower_p7p1/statistics/rx_nohandler
16568
$ cat /sys/devices/virtual/net/bond0/lower_p5p2/statistics/rx_nohandler
16583
$ cat /sys/devices/virtual/net/bond0/statistics/rx_nohandler
33151

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b5605..6587929 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3309,6 +3309,7 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
 		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
 		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
+		stats->rx_nohandler += sstats->rx_nohandler - pstats->rx_nohandler;
 
 		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
 		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
-- 
1.8.3.1
