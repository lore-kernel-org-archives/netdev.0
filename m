From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: constify mdiobb_ops structures
Date: Fri, 13 Jan 2017 23:32:26 +0530
Message-ID: <1484330546-16569-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, pantelis.antoniou@gmail.com,
        vbordug@ru.mvista.com, sergei.shtylyov@cogentembedded.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-renesas-soc@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare mdiobb_ops structures as const as they are only stored in the
ops field of mdiobb_ctrl structures. This field is of type const, so
mdiobb_ops structures having this property can be declared const too.
Done using Coccinelle:

@r disable optional_qualifier@
identifier x;
position p;
@@
static struct mdiobb_ops x@p={...};

@ok@
struct bb_info bitbang;
struct ravb_private priv;
struct ax_device ax;
struct mdio_gpio_info bb;
identifier r.x;
position p;
@@
(
bitbang.ctrl.ops=&x@p
|
priv.mdiobb.ops=&x@p
|
ax.bb_ctrl.ops=&x@p
|
bb.ctrl.ops=&x@p
)

@bad@
position p != {r.p,ok.p};
identifier r.x;
@@
x@p

@depends on !bad disable optional_qualifier@
identifier r.x;
@@
+const
struct mdiobb_ops x;

Before and after size details:

File size before:
   text	   data	    bss	    dec	    hex	filename
  13293	   1203	     16	  14512	   38b0 net/ethernet/8390/ax88796.o
File size after:
   text	   data	    bss	    dec	    hex	filename
  13357	   1139	     16	  14512	   38b0 net/ethernet/8390/ax88796.o

File size before: 
   text	   data	    bss	    dec	    hex	filename
   1440	    100	      0	   1540	    604 freescale/fs_enet/mii-bitbang.o
File size after: Remains the same

File size before:
   text	   data	    bss	    dec	    hex	filename
  19000	    192	     16	  19208	   4b08	net/ethernet/renesas/ravb_main.o
File size after: Remains the same

File size before:
   text	   data	    bss	    dec	    hex	filename
  28501	   1568	      8	  30077	   757d net/ethernet/renesas/sh_eth.o
File size after:
   text	   data	    bss	    dec	    hex	filename
  28565	   1504	      8	  30077	   757d net/ethernet/renesas/sh_eth.o

File size before:
   text	   data	    bss	    dec	    hex	filename
   1859	    248	      0	   2107	    83b	drivers/net/phy/mdio-gpio.o
File size after:
   text	   data	    bss	    dec	    hex	filename
   1915	    192	      0	   2107	    83b	drivers/net/phy/mdio-gpio.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/8390/ax88796.c                  | 2 +-
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c | 2 +-
 drivers/net/ethernet/renesas/ravb_main.c             | 2 +-
 drivers/net/ethernet/renesas/sh_eth.c                | 2 +-
 drivers/net/phy/mdio-gpio.c                          | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index b0a3b85..e977671 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -585,7 +585,7 @@ static int ax_bb_get_data(struct mdiobb_ctrl *ctrl)
 	return reg_memr & AX_MEMR_MDI ? 1 : 0;
 }
 
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = ax_bb_mdc,
 	.set_mdio_dir = ax_bb_dir,
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 1f015ed..c8e5d88 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -100,7 +100,7 @@ static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
 	in_be32(bitbang->dat);
 }
 
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = mdc,
 	.set_mdio_dir = mdio_dir,
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 92d7692..1b0acd1 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -171,7 +171,7 @@ static int ravb_get_mdio_data(struct mdiobb_ctrl *ctrl)
 }
 
 /* MDIO bus control struct */
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = ravb_set_mdc,
 	.set_mdio_dir = ravb_set_mdio_dir,
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 00fafab..6ef5dd8 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1052,7 +1052,7 @@ static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
 }
 
 /* mdio bus control struct */
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = sh_mdc_ctrl,
 	.set_mdio_dir = sh_mmd_ctrl,
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 27ab630..97333d5 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -122,7 +122,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	gpio_set_value_cansleep(bitbang->mdc, what ^ bitbang->mdc_active_low);
 }
 
-static struct mdiobb_ops mdio_gpio_ops = {
+static const struct mdiobb_ops mdio_gpio_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = mdc_set,
 	.set_mdio_dir = mdio_dir,
-- 
1.9.1
