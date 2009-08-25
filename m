From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/9] s2io.c: use kzalloc
Date: Mon, 24 Aug 2009 20:29:43 -0700
Message-ID: <416bba94359006196d099960489036e9c97c9ed7.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 75f2209..134cdb3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3834,7 +3834,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	int size;
 
 	size = nic->num_entries * sizeof(struct msix_entry);
-	nic->entries = kmalloc(size, GFP_KERNEL);
+	nic->entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
 			__func__);
@@ -3843,10 +3843,8 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
 
-	memset(nic->entries, 0, size);
-
 	size = nic->num_entries * sizeof(struct s2io_msix_entry);
-	nic->s2io_entries = kmalloc(size, GFP_KERNEL);
+	nic->s2io_entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
 			__func__);
@@ -3857,7 +3855,6 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 		return -ENOMEM;
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
-	memset(nic->s2io_entries, 0, size);
 
 	nic->entries[0].entry = 0;
 	nic->s2io_entries[0].entry = 0;
-- 
1.6.3.1.10.g659a0.dirty
