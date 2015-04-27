From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH 1/2] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Mon, 27 Apr 2015 13:00:48 +0800
Message-ID: <553DC280.6080503@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ACPI will manage WiFi chip's power state during suspend/resume
process on some tablet platforms(such as ASUS T100TA). This is
not supported by brcmfmac driver now, and the context of WiFi
chip will be damaged after resume. This patch disconnects the
relationship between WiFi chip and it's ACPI companion, and
prohibit ACPI PM for it.

Signed-off-by: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 9b508bd..fdf8feb 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -1114,6 +1114,7 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 	int err;
 	struct brcmf_sdio_dev *sdiodev;
 	struct brcmf_bus *bus_if;
+	struct device *dev;
 
 	brcmf_dbg(SDIO, "Enter\n");
 	brcmf_dbg(SDIO, "Class=%x\n", func->class);
@@ -1121,6 +1122,10 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 	brcmf_dbg(SDIO, "sdio device ID: 0x%04x\n", func->device);
 	brcmf_dbg(SDIO, "Function#: %d\n", func->num);
 
+	/* prohibit ACPI power management for this device */
+	dev = &func->dev;
+	dev->fwnode = NULL;
+
 	/* Consume func num 1 but dont do anything with it. */
 	if (func->num == 1)
 		return 0;
-- 1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
