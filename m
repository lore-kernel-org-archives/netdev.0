From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/6] netprio_cgroup: fix an off-by-one bug
Date: Wed, 01 Feb 2012 14:55:13 +0800
Message-ID: <4F28E1D1.900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/core/netprio_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 3a9fd48..a296cbb 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -107,7 +107,7 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 static void update_netdev_tables(void)
 {
 	struct net_device *dev;
-	u32 max_len = atomic_read(&max_prioidx);
+	u32 max_len = atomic_read(&max_prioidx) + 1;
 	struct netprio_map *map;
 
 	rtnl_lock();
-- 
1.7.3.1
