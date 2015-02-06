From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] brcmfmac: use msecs_to_jiffies for time conversion
Date: Fri,  6 Feb 2015 05:26:45 -0500
Message-ID: <1423218405-17624-1-git-send-email-hofrat@osadl.org>
Cc: Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var).

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_BRCMFMAC=m,
CONFIG_MMC=m, CONFIG_BRCMFMAC_SDIO=y

Patch is against 3.19.0-rc7 (localversion-next is -next-20150204)

 drivers/net/wireless/brcm80211/brcmfmac/sdio.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
index 5e9d208..4f9469b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
@@ -3972,7 +3972,7 @@ brcmf_sdio_watchdog(unsigned long data)
 		/* Reschedule the watchdog */
 		if (bus->wd_timer_valid)
 			mod_timer(&bus->timer,
-				  jiffies + BRCMF_WD_POLL_MS * HZ / 1000);
+				  jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS));
 	}
 }
 
@@ -4291,13 +4291,13 @@ void brcmf_sdio_wd_timer(struct brcmf_sdio *bus, uint wdtick)
 			   dynamically changed or in the first instance
 			 */
 			bus->timer.expires =
-				jiffies + BRCMF_WD_POLL_MS * HZ / 1000;
+				jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS);
 			add_timer(&bus->timer);
 
 		} else {
 			/* Re arm the timer, at last watchdog period */
 			mod_timer(&bus->timer,
-				jiffies + BRCMF_WD_POLL_MS * HZ / 1000);
+				jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS));
 		}
 
 		bus->wd_timer_valid = true;
-- 
1.7.10.4
