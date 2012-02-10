From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/3] netprio_cgroup: fix an off-by-one bug
Date: Fri, 10 Feb 2012 10:43:36 -0500
Message-ID: <1328888618-16208-2-git-send-email-nhorman@tuxdriver.com>
References: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58490 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab2BJPoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 10:44:09 -0500
In-Reply-To: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  # mount -t cgroup xxx /mnt
  # mkdir /mnt/tmp
  # cat /mnt/tmp/net_prio.ifpriomap
  lo 0
  eth0 0
  virbr0 0
  # echo 'lo 999' > /mnt/tmp/net_prio.ifpriomap
  # cat /mnt/tmp/net_prio.ifpriomap
  lo 999
  eth0 0
  virbr0 4101267344

We got weired output, because we exceeded the boundary of the array.
We may even crash the kernel..

Origionally-authored-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/netprio_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 9ae183a..72c6387 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -108,7 +108,7 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 static void update_netdev_tables(void)
 {
 	struct net_device *dev;
-	u32 max_len = atomic_read(&max_prioidx);
+	u32 max_len = atomic_read(&max_prioidx) + 1;
 	struct netprio_map *map;
 
 	rtnl_lock();
-- 
1.7.7.6
