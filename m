From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 22/22] IB/mlx4: fix sprintf format warning
Date: Fri, 14 Jul 2017 14:07:14 +0200
Message-ID: <20170714120720.906842-23-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Leon Romanovsky <leon@kernel.org>,
        Adit Ranadive <aditr@vmware.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        linux-rdma@vger.kernel.org
To: linux-kernel@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 points out that a negative port_num value would overflow
the string buffer:

drivers/infiniband/hw/mlx4/sysfs.c: In function 'mlx4_ib_device_register_sysfs':
drivers/infiniband/hw/mlx4/sysfs.c:251:16: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
drivers/infiniband/hw/mlx4/sysfs.c:251:2: note: 'sprintf' output between 2 and 11 bytes into a destination of size 10
drivers/infiniband/hw/mlx4/sysfs.c:303:17: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
drivers/infiniband/hw/mlx4/sysfs.c:303:3: note: 'sprintf' output between 2 and 11 bytes into a destination of size 10

While we should be able to assume that port_num is positive here,
making the buffer one byte longer has no downsides and avoids the
warning.

Fixes: c1e7e466120b ("IB/mlx4: Add iov directory in sysfs under the ib device")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/infiniband/hw/mlx4/sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx4/sysfs.c b/drivers/infiniband/hw/mlx4/sysfs.c
index 0ba5ba7540c8..e219093d2764 100644
--- a/drivers/infiniband/hw/mlx4/sysfs.c
+++ b/drivers/infiniband/hw/mlx4/sysfs.c
@@ -221,7 +221,7 @@ void del_sysfs_port_mcg_attr(struct mlx4_ib_dev *device, int port_num,
 static int add_port_entries(struct mlx4_ib_dev *device, int port_num)
 {
 	int i;
-	char buff[10];
+	char buff[11];
 	struct mlx4_ib_iov_port *port = NULL;
 	int ret = 0 ;
 	struct ib_port_attr attr;
-- 
2.9.0
