From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] devlink: fix devlink_sb_register prototype
Date: Sat, 16 Apr 2016 22:27:06 +0200
Message-ID: <1460838446-1246570-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Ido Schimmel <idosch@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The devlink shared buffer interface contains two different
prototypes for devlink_sb_register, and the one that is
used when NET_DEVLINK is disabled does not work:

drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c: In function 'mlxsw_sp_buffers_init':
drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c:547:9: error: too many arguments to function 'devlink_sb_register'
  return devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,

This makes the two prototypes have the same argument list.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: bf7974710a40 ("devlink: add shared buffer configuration")
---
 include/net/devlink.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index be64218e0254..1d45b61cb320 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -184,7 +184,9 @@ static inline void devlink_port_split_set(struct devlink_port *devlink_port,
 static inline int devlink_sb_register(struct devlink *devlink,
 				      unsigned int sb_index, u32 size,
 				      u16 ingress_pools_count,
-				      u16 egress_pools_count, u16 tc_count)
+				      u16 egress_pools_count,
+				      u16 ingress_tc_count,
+				      u16 egress_tc_count)
 {
 	return 0;
 }
-- 
2.7.0
