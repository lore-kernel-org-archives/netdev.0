From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] rds: drop "select LLIST"
Date: Sun, 13 Nov 2011 14:36:37 +0100
Message-ID: <1321191397.20271.62.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 1bc144b625 ("net, rds, Replace xlist in net/rds/xlist.h with
llist") added "select LLIST" to the RDS_RDMA Kconfig entry. But there is
no Kconfig symbol named LLIST. The select statement for that symbol is a
nop. Drop it.

lib/llist.o is builtin, so all that's needed to use the llist
functionality is to include linux/llist.h, which this commit also did.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Tested with "yes "" | make config" before and after applying this patch.
Identical .config files were generated, as was expected

 net/rds/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index 4cf6dc7..ec753b3 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -9,7 +9,6 @@ config RDS
 
 config RDS_RDMA
 	tristate "RDS over Infiniband and iWARP"
-	select LLIST
 	depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
 	---help---
 	  Allow RDS to use Infiniband and iWARP as a transport.
-- 
1.7.4.4
