From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2] net: xilinx: constify net_device_ops structure
Date: Sat, 21 Jan 2017 12:28:58 +0530
Message-ID: <1484981938-29829-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare net_device_ops structure as const as it is only stored in
the netdev_ops field of a net_device structure. This field is of type
const, so net_device_ops structures having same properties can be made
const too.
Done using Coccinelle:

@r1 disable optional_qualifier@
identifier i;
position p;
@@
static struct net_device_ops i@p={...};

@ok1@
identifier r1.i;
position p;
struct net_device ndev;
@@
ndev.netdev_ops=&i@p

@bad@
position p!={r1.p,ok1.p};
identifier r1.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
+const
struct net_device_ops i;

File size before:
   text	   data	    bss	    dec	    hex	filename
   6201	    744	      0	   6945	   1b21 ethernet/xilinx/xilinx_emaclite.o

File size after:
   text	   data	    bss	    dec	    hex	filename
   6745	    192	      0	   6937	   1b19 ethernet/xilinx/xilinx_emaclite.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
Changes in v2:
* Corrected the commit message.

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 93dc10b..546f569 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1065,7 +1065,7 @@ static bool get_bool(struct platform_device *ofdev, const char *s)
 	}
 }
 
-static struct net_device_ops xemaclite_netdev_ops;
+static const struct net_device_ops xemaclite_netdev_ops;
 
 /**
  * xemaclite_of_probe - Probe method for the Emaclite device.
@@ -1219,7 +1219,7 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 }
 #endif
 
-static struct net_device_ops xemaclite_netdev_ops = {
+static const struct net_device_ops xemaclite_netdev_ops = {
 	.ndo_open		= xemaclite_open,
 	.ndo_stop		= xemaclite_close,
 	.ndo_start_xmit		= xemaclite_send,
-- 
1.9.1
