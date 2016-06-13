From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/3] infiniband: rxe: add UDP_TUNNEL dependency
Date: Mon, 13 Jun 2016 14:54:54 +0200
Message-ID: <1465822509-4167617-2-git-send-email-arnd@arndb.de>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Moni Shoua <monis@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Kamal Heib <kamalh@mellanox.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added rxe driver links against the UDP tunneling code,
which causes build errors when CONFIG_UDP_TUNNEL is disabled:

ERROR: "setup_udp_tunnel_sock" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!
ERROR: "udp_tunnel_sock_release" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!
ERROR: "udp_sock_create4" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!

This adds a Kconfig dependency to prevent the invalid configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/infiniband/hw/rxe/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/rxe/Kconfig b/drivers/infiniband/hw/rxe/Kconfig
index 649b7be11eb8..a199d0df31d0 100644
--- a/drivers/infiniband/hw/rxe/Kconfig
+++ b/drivers/infiniband/hw/rxe/Kconfig
@@ -1,6 +1,7 @@
 config INFINIBAND_RXE
 	tristate "Software RDMA over Ethernet (RoCE) driver"
 	depends on INET && PCI && INFINIBAND
+	depends on NET_UDP_TUNNEL
 	---help---
 	This driver implements the InfiniBand RDMA transport over
 	the Linux network stack. It enables a system with a
-- 
2.7.0
