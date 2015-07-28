From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 0/3] net: netcp: bug fixes for dynamic module support
Date: Tue, 28 Jul 2015 18:20:11 -0400
Message-ID: <1438122014-24744-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes few bugs to allow keystone netcp modules to be
dynamically loaded and removed. Currently it allows following
sequence multiple times
  
 insmod cpsw_ale.ko
 insmod davinci_mdio.ko
 insmod keystone_netcp.ko
 insmod keystone_netcp_ethss.ko
 ifup eth0
 ifup eth1
 ping <hosts on eth0>
 ping <hosts on eth1>
 ifdown eth1
 ifdown eth0
 rmmod keystone_netcp_ethss.ko
 rmmod keystone_netcp.ko
 rmmod davinci_mdio.ko
 rmmod cpsw_ale.ko

Murali Karicheri (3):
  net: netcp: fix cleanup interface list in netcp_remove()
  net: netcp: ethss: fix up incorrect use of list api
  net: netcp: ethss: cleanup gbe_probe() and gbe_remove() functions

 drivers/net/ethernet/ti/netcp_core.c  | 14 +++++++---
 drivers/net/ethernet/ti/netcp_ethss.c | 49 ++++++++++++++---------------------
 2 files changed, 30 insertions(+), 33 deletions(-)

-- 
1.9.1
