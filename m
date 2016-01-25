From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 3/3] defxx: fix build warning
Date: Mon, 25 Jan 2016 11:45:07 +0530
Message-ID: <1453702507-736-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are getting many build warning about:
'bar_start' may be used uninitialized
and
'bar_len' may be used uninitialized

They are not actually uninitialized as dfx_get_bars() will initialize
them properly. But still lets have them initialized just to satisfy the
compiler.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/fddi/defxx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 7f975a2..4113535 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -533,8 +533,8 @@ static int dfx_register(struct device *bdev)
 	const char *print_name = dev_name(bdev);
 	struct net_device *dev;
 	DFX_board_t	  *bp;			/* board pointer */
-	resource_size_t bar_start[3];		/* pointers to ports */
-	resource_size_t bar_len[3];		/* resource length */
+	resource_size_t bar_start[3] = {0, 0, 0};	/* pointers to ports */
+	resource_size_t bar_len[3] = {0, 0, 0};		/* resource length */
 	int alloc_size;				/* total buffer size used */
 	struct resource *region;
 	int err = 0;
@@ -3697,8 +3697,8 @@ static void dfx_unregister(struct device *bdev)
 	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
-	resource_size_t bar_start[3];		/* pointers to ports */
-	resource_size_t bar_len[3];		/* resource lengths */
+	resource_size_t bar_start[3] = {0, 0, 0};	/* pointers to ports */
+	resource_size_t bar_len[3] = {0, 0, 0};		/* resource lengths */
 	int		alloc_size;		/* total buffer size used */
 
 	unregister_netdev(dev);
-- 
1.9.1
