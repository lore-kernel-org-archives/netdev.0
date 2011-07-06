From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the staging tree
Date: Wed, 6 Jul 2011 15:02:49 +1000
Message-ID: <20110706150249.f2c67b43.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

After merging the staging tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:599:24: error: field 'tasklet' has incomplete type
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c: In function 'brcmf_sdbrcm_bus_stop':
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:3068:3: error: implicit declaration of function 'tasklet_kill'
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c: In function 'brcmf_sdbrcm_probe':
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:5376:3: error: implicit declaration of function 'tasklet_init'
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c: In function 'brcmf_sdbrcm_probe_attach':
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:5505:14: warning: cast to pointer from integer of different size
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c: In function 'brcmf_sdbrcm_chip_recognition':
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:6056:19: warning: cast from pointer to integer of different size
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c: In function 'brcmf_sdbrcm_dpc_tasklet':
drivers/staging/brcm80211/brcmfmac/dhd_sdio.c:6593:4: error: implicit declaration of function 'tasklet_schedule'

Caused by commit a6b7a407865a ("net: remove interrupt.h inclusion from netdevice.h") from the net tree interacting with commit  ("") from the atsging tree.

I have applied the following merge fixup patch for today (it should be
applicable to the staging tree directly).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 6 Jul 2011 14:54:48 +1000
Subject: [PATCH] staging: use of tasklets requires including interrupt.h

The implicit include of linux/interrupt.h is being removed from
netdevice.h.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/staging/brcm80211/brcmfmac/dhd_sdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/brcm80211/brcmfmac/dhd_sdio.c b/drivers/staging/brcm80211/brcmfmac/dhd_sdio.c
index da5a2ff..78a6a0c 100644
--- a/drivers/staging/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/staging/brcm80211/brcmfmac/dhd_sdio.c
@@ -20,6 +20,7 @@
 #include <linux/printk.h>
 #include <linux/pci_ids.h>
 #include <linux/netdevice.h>
+#include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/mmc/sdio.h>
 #include <linux/mmc/sdio_func.h>
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
