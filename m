From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/5] drivers/net/wireless/brcm80211/brcmsmac/dma.c: eliminate a null pointer dereference
Date: Sat, 29 Oct 2011 01:58:14 +0200
Message-ID: <1319846297-2985-2-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Delete di->name from the error reporting code, as it is meaningless if di
is NULL.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
expression E, E1;
identifier f;
statement S1,S2,S3;
@@

if (E == NULL)
{
  ... when != if (E == NULL || ...) S1 else S2
      when != E = E1
*E->f
  ... when any
  return ...;
}
else S3
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/brcm80211/brcmsmac/dma.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index b56a302..1d66f53 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -361,7 +361,7 @@ static uint _dma_ctrlflags(struct dma_info *di, uint mask, uint flags)
 	uint dmactrlflags = di->dma.dmactrlflags;
 
 	if (di == NULL) {
-		DMA_ERROR(("%s: _dma_ctrlflags: NULL dma handle\n", di->name));
+		DMA_ERROR(("_dma_ctrlflags: NULL dma handle\n"));
 		return 0;
 	}
 
