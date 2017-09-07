From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: tulip: Constify tulip_tbl
Date: Thu, 7 Sep 2017 12:35:14 -0700
Message-ID: <20170907193514.GA114400@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like all users of tulip_tbl are reads, so mark this table
as read-only.

$ git grep tulip_tbl  # edited to avoid line-wraps...
interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ...
interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ...
interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ...
interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs | TimerInt,
pnic.c:      iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
tulip.h:     extern struct tulip_chip_table tulip_tbl[];
tulip_core.c:struct tulip_chip_table tulip_tbl[] = {
tulip_core.c:iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR5);
tulip_core.c:iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
tulip_core.c:setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
tulip_core.c:const char *chip_name = tulip_tbl[chip_idx].chip_name;
tulip_core.c:if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size)
tulip_core.c:ioaddr =  pci_iomap(..., tulip_tbl[chip_idx].io_size);
tulip_core.c:tp->flags = tulip_tbl[chip_idx].flags;
tulip_core.c:setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
tulip_core.c:INIT_WORK(&tp->media_work, tulip_tbl[tp->chip_id].media_task);

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: netdev@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/dec/tulip/tulip.h      | 2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip.h b/drivers/net/ethernet/dec/tulip/tulip.h
index 38431a155f09..06660dbc44b7 100644
--- a/drivers/net/ethernet/dec/tulip/tulip.h
+++ b/drivers/net/ethernet/dec/tulip/tulip.h
@@ -515,7 +515,7 @@ void comet_timer(unsigned long data);
 extern int tulip_debug;
 extern const char * const medianame[];
 extern const char tulip_media_cap[];
-extern struct tulip_chip_table tulip_tbl[];
+extern const struct tulip_chip_table tulip_tbl[];
 void oom_timer(unsigned long data);
 extern u8 t21040_csr13[];
 
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 84394b43c0a1..851b6d1f5a42 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -138,7 +138,7 @@ static void tulip_timer(unsigned long data)
  * It is indexed via the values in 'enum chips'
  */
 
-struct tulip_chip_table tulip_tbl[] = {
+const struct tulip_chip_table tulip_tbl[] = {
   { }, /* placeholder for array, slot unused currently */
   { }, /* placeholder for array, slot unused currently */
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
