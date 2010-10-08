From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 4/5] rds: stop including asm-generic/bitops/le.h directly
Date: Fri,  8 Oct 2010 19:03:12 +0900
Message-ID: <1286532193-29814-4-git-send-email-akinobu.mita@gmail.com>
References: <1286532193-29814-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Andy Grover <andy.grover@oracle.com>, rds-devel@oss.oracle.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286532193-29814-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

asm-generic/bitops/le.h is only intended to be included directly from
asm-generic/bitops/ext2-non-atomic.h or asm-generic/bitops/minix-le.h
which implements generic ext2 or minix bit operations.

This stops including asm-generic/bitops/le.h directly and use ext2
non-atomic bit operations instead.

An alternative approach is introducing little endian bit operations
in linux/bitops.h. But it needs to touch more files than this change does.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andy Grover <andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/rds/cong.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index 0871a29..5bd0f36 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -33,8 +33,7 @@
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/rbtree.h>
-
-#include <asm-generic/bitops/le.h>
+#include <linux/bitops.h>
 
 #include "rds.h"
 
@@ -285,7 +284,7 @@ void rds_cong_set_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	generic___set_le_bit(off, (void *)map->m_page_addrs[i]);
+	ext2_set_bit(off, (void *)map->m_page_addrs[i]);
 }
 
 void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
@@ -299,7 +298,7 @@ void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	generic___clear_le_bit(off, (void *)map->m_page_addrs[i]);
+	ext2_clear_bit(off, (void *)map->m_page_addrs[i]);
 }
 
 static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
@@ -310,7 +309,7 @@ static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	return generic_test_le_bit(off, (void *)map->m_page_addrs[i]);
+	return ext2_test_bit(off, (void *)map->m_page_addrs[i]);
 }
 
 void rds_cong_add_socket(struct rds_sock *rs)
-- 
1.7.1.231.gd0b16
