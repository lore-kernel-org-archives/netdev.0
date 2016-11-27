From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] wireless: ath: ath9k: constify ath_bus_ops structure
Date: Sun, 27 Nov 2016 22:33:26 +0530
Message-ID: <1480266206-26732-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, ath9k-devel@qca.qualcomm.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare the structure ath_bus_ops as const as it is only passed as an
argument to the function ath9k_init_device. This argument is of type
const struct ath_bus_ops *, so ath_bus_ops structures with this property
can be declared as const.
Done using Coccinelle:
@r1 disable optional_qualifier @
identifier i;
position p;
@@
static struct ath_bus_ops i@p = {...};

@ok1@
identifier r1.i;
position p;
expression e1,e2;
@@
ath9k_init_device(e1,e2,&i@p)

@bad@
position p!={r1.p,ok1.p};
identifier r1.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
static
+const
struct ath_bus_ops i={...};

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
+const
struct ath_bus_ops i;

File size before:
   text	   data	    bss	    dec	    hex	filename
   1295	    232	      0	   1527	    5f7	ath/ath9k/ahb.o

File size after:
   text	   data	    bss	    dec	    hex	filename
   1359	    176	      0	   1535	    5ff	ath/ath9k/ahb.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/ath/ath9k/ahb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index bea6186..2bd982c 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -62,7 +62,7 @@ static bool ath_ahb_eeprom_read(struct ath_common *common, u32 off, u16 *data)
 	return false;
 }
 
-static struct ath_bus_ops ath_ahb_bus_ops  = {
+static const struct ath_bus_ops ath_ahb_bus_ops  = {
 	.ath_bus_type = ATH_AHB,
 	.read_cachesize = ath_ahb_read_cachesize,
 	.eeprom_read = ath_ahb_eeprom_read,
-- 
1.9.1
