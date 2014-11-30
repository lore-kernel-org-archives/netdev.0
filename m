From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 30 Nov 2014 13:04:31 +0100
Message-ID: <547B07CF.90501@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C5D1F.108@msgid.tls.msk.ru> <546CD94D.9060509@broadcom.com> <546CF66A.3000207@msgid.tls.msk.ru> <546D04EE.1030200@msgid.tls.msk.ru> <5471AC29.6040009@broadcom.com> <5475A2DC.80502@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------030701070605020304000106"
Cc: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	brcm80211 development <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5475A2DC.80502-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--------------030701070605020304000106
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

On 26-11-14 10:52, Michael Tokarev wrote:
> I'm sorry this took so long - I was AFK during weekend and had
> to deal with a huge backlog after that.  Now it is all sorted.
> 
> 23.11.2014 12:43, Arend van Spriel wrote:
>> On 19-11-14 22:00, Michael Tokarev wrote:
> []
>> Well, it shows tx looks ok, but with download there is not much of that
>> going on. At least no large packets. However, I did find some missing
>> pieces related to bt-coex. Given that you device is a wifi-bt combo card
>> that is likely an issue for you. One of the missing pieces looks in
>> sprom for parameters and that is provided by bcma. However, it does not
>> seem to extract bt-coex related stuff. So I have attached a patch based
>> on 3.18-rc5 for bcma that dumps the sprom contents. Could you sent that
>> content to me.
> 
> Here we go.  I had to replace pr_debug with pr_err - haven't looked yet,
> but the thing is that pr_debug isn't even being compiled into the kernel
> here, all the messages are not present in the compiled modules.

Thanks. Did not find what I was looking for, but I started working on
integrating btcoex related functionality. The attached patch will print
some info so I can focus on the required functionality for your device.
It is based on 3.18-rc5.

Regards,
Arend

> [  525.693474] bcma: bcmasprom:
> [  525.693528] bcma:
> 	
> [  525.693592] bcma: 2801
> [  525.693613] bcma: 0000
> [  525.693659] bcma: 1795
> [  525.693679] bcma: 103C
> [  525.693725] bcma: 0070
> [  525.693746] bcma: EDBE
> [  525.693791] bcma: 0000
> [  525.693811] bcma: 2BC4
> [  525.693856] bcma: 2A64
> [  525.693877] bcma: 2964
> [  525.693922] bcma:
> 	
> [  525.693938] bcma: 2C64
> [  525.693984] bcma: 3CE7
> [  525.694004] bcma: 46FF
> [  525.694049] bcma: 47FF
> [  525.694070] bcma: 0C00
> [  525.694115] bcma: 0820
> [  525.694136] bcma: 0030
> [  525.694181] bcma: 1002
> [  525.694202] bcma: 9F28
> [  525.694247] bcma: 5D44
> [  525.694267] bcma:
> 	
> [  525.694329] bcma: 8080
> [  525.694349] bcma: 1D8F
> [  525.694395] bcma: 0032
> [  525.694415] bcma: 0100
> [  525.694461] bcma: DF00
> [  525.694481] bcma: 71F5
> [  525.694526] bcma: 8400
> [  525.694547] bcma: 0083
> [  525.694592] bcma: 8500
> [  525.694613] bcma: 2010
> [  525.694658] bcma:
> 	
> [  525.694674] bcma: 0001
> [  525.694719] bcma: 0000
> [  525.694740] bcma: 0000
> [  525.694785] bcma: 0000
> [  525.694805] bcma: 0000
> [  525.694850] bcma: 0000
> [  525.694871] bcma: 0000
> [  525.694916] bcma: 0000
> [  525.694937] bcma: 0000
> [  525.694982] bcma: 0000
> [  525.695002] bcma:
> 	
> [  525.695063] bcma: 0000
> [  525.695084] bcma: 0000
> [  525.695129] bcma: 1008
> [  525.695150] bcma: 0305
> [  525.695195] bcma: 0000
> [  525.695215] bcma: 0000
> [  525.695261] bcma: 0000
> [  525.695281] bcma: 0000
> [  525.695326] bcma: 4727
> [  525.695347] bcma: 8000
> [  525.695392] bcma:
> 	
> [  525.695409] bcma: 0002
> [  525.695454] bcma: 0000
> [  525.695474] bcma: 1800
> [  525.695520] bcma: 1800
> [  525.695561] bcma: 0000
> [  525.695610] bcma: 0000
> [  525.695631] bcma: 0000
> [  525.695677] bcma: 0000
> [  525.695698] bcma: 0000
> [  525.695746] bcma: 0000
> [  525.695766] bcma:
> 	
> [  525.695827] bcma: 0000
> [  525.695848] bcma: 0000
> [  525.695893] bcma: 0000
> [  525.695914] bcma: 0000
> [  525.695961] bcma: 5372
> [  525.695982] bcma: 1107
> [  525.696027] bcma: 2201
> [  525.696048] bcma: 0040
> [  525.696093] bcma: 0884
> [  525.696116] bcma: 0000
> [  525.696161] bcma:
> 	
> [  525.696178] bcma: E006
> [  525.696223] bcma: E659
> [  525.696244] bcma: 5F5A
> [  525.696290] bcma: 5856
> [  525.696310] bcma: 0001
> [  525.696356] bcma: FFFF
> [  525.696376] bcma: 83FF
> [  525.696422] bcma: FFFF
> [  525.696443] bcma: 0003
> [  525.696488] bcma: 0202
> [  525.696508] bcma:
> 	
> [  525.696570] bcma: FFFF
> [  525.696590] bcma: 0011
> [  525.698381] bcma: 017A
> [  525.698402] bcma: 0000
> [  525.700181] bcma: 0000
> [  525.700202] bcma: 0000
> [  525.701936] bcma: 0000
> [  525.701957] bcma: 0201
> [  525.703650] bcma: 0000
> [  525.703672] bcma: 7800
> [  525.705278] bcma:
> 	
> [  525.706808] bcma: 6410
> [  525.708296] bcma: E398
> [  525.708318] bcma: 0008
> [  525.709774] bcma: 0000
> [  525.709796] bcma: 0000
> [  525.711186] bcma: 0000
> [  525.711207] bcma: 0044
> [  525.712532] bcma: 2400
> [  525.712556] bcma: FCF7
> [  525.713867] bcma: 0089
> [  525.713888] bcma:
> 	
> [  525.716500] bcma: 0000
> [  525.716524] bcma: 0000
> [  525.717834] bcma: 0000
> [  525.717855] bcma: 0000
> [  525.719195] bcma: 0000
> [  525.719217] bcma: 0000
> [  525.720530] bcma: 0000
> [  525.720551] bcma: 0000
> [  525.721862] bcma: 0000
> [  525.721882] bcma: 0000
> [  525.723176] bcma:
> 	
> [  525.724400] bcma: 0000
> [  525.725678] bcma: 0000
> [  525.725699] bcma: 0048
> [  525.726996] bcma: FED2
> [  525.727017] bcma: 15D9
> [  525.728308] bcma: FAC6
> [  525.728329] bcma: 0000
> [  525.729642] bcma: 0000
> [  525.729664] bcma: 0000
> [  525.730958] bcma: 0000
> [  525.730978] bcma:
> 	
> [  525.733526] bcma: 0000
> [  525.733549] bcma: 0000
> [  525.734827] bcma: 0000
> [  525.734848] bcma: 0000
> [  525.736155] bcma: 0000
> [  525.736179] bcma: 0000
> [  525.737466] bcma: 0000
> [  525.737487] bcma: 0000
> [  525.738764] bcma: 0000
> [  525.738785] bcma: 0000
> [  525.740049] bcma:
> 	
> [  525.741240] bcma: 0000
> [  525.742501] bcma: 0000
> [  525.742522] bcma: 0000
> [  525.743806] bcma: 0000
> [  525.743827] bcma: 0000
> [  525.745111] bcma: 0000
> [  525.745132] bcma: 0000
> [  525.746433] bcma: 0000
> [  525.746456] bcma: 0000
> [  525.747725] bcma: 0000
> [  525.747746] bcma:
> 	
> [  525.750251] bcma: 0000
> [  525.750272] bcma: 0000
> [  525.751532] bcma: 0000
> [  525.751553] bcma: 0000
> [  525.752847] bcma: 0000
> [  525.752871] bcma: 0000
> [  525.754150] bcma: 0000
> [  525.754171] bcma: 0000
> [  525.755441] bcma: 0000
> [  525.755462] bcma: 0000
> [  525.756717] bcma:
> 	
> [  525.757900] bcma: 0000
> [  525.759148] bcma: 0000
> [  525.759170] bcma: 0000
> [  525.760436] bcma: 0000
> [  525.760457] bcma: 0000
> [  525.761720] bcma: 0000
> [  525.761741] bcma: 0000
> [  525.763023] bcma: 0000
> [  525.763047] bcma: 0000
> [  525.764301] bcma: 0000
> [  525.764321] bcma:
> 	
> [  525.766790] bcma: 0000
> [  525.766813] bcma: 1111
> [  525.768057] bcma: 1111
> [  525.768078] bcma: 0000
> [  525.769355] bcma: 0000
> [  525.769378] bcma: 0000
> [  525.770631] bcma: 0000
> [  525.770652] bcma: 0000
> [  525.771898] bcma: 0000
> [  525.771919] bcma: 2222
> [  525.773158] bcma:
> 	
> [  525.774325] bcma: 3222
> [  525.775540] bcma: 0000
> [  525.775561] bcma: 0000
> [  525.776816] bcma: 0000
> [  525.776840] bcma: 0000
> [  525.778089] bcma: 0000
> [  525.778110] bcma: 0000
> [  525.779355] bcma: 0000
> [  525.779380] bcma: 0000
> [  525.780600] bcma: 0000
> [  525.780621] bcma:
> 	
> [  525.783015] bcma: 0000
> [  525.783038] bcma: 0000
> [  525.784247] bcma: 0000
> [  525.784268] bcma: 0000
> [  525.785500] bcma: 0000
> [  525.785521] bcma: 0000
> [  525.786759] bcma: 0000
> [  525.786781] bcma: 0000
> [  525.787995] bcma: 0000
> [  525.788016] bcma: 0000
> [  525.789217] bcma:
> 	
> [  525.790337] bcma: 0000
> [  525.791505] bcma: 0000
> [  525.791525] bcma: 0000
> [  525.792740] bcma: 0000
> [  525.792765] bcma: 0000
> [  525.793965] bcma: 0000
> [  525.793986] bcma: 0000
> [  525.795168] bcma: 0000
> [  525.795189] bcma: 0000
> [  525.796375] bcma: 0000
> [  525.796399] bcma:
> 	
> [  525.798682] bcma: 0000
> [  525.798703] bcma: 0000
> [  525.799885] bcma: 0000
> [  525.799906] bcma: 0000
> [  525.801038] bcma: 0000
> [  525.801058] bcma: 0000
> [  525.802177] bcma: 0000
> [  525.802197] bcma: 0000
> [  525.803320] bcma: 0000
> [  525.803340] bcma: 0000
> [  525.804433] bcma:
> 	
> [  525.805460] bcma: 0000
> [  525.806547] bcma: 0000
> [  525.806567] bcma: 0000
> [  525.807671] bcma: 0000
> [  525.807691] bcma: 0000
> [  525.808777] bcma: 0000
> [  525.808796] bcma: 0000
> [  525.809899] bcma: 0000
> [  525.809919] bcma: 0000
> [  525.821789] bcma: bus0: Bus registered
> 
> Thanks,
> 
> /mjt
> 


--------------030701070605020304000106
Content-Type: text/x-patch;
	name="0001-brcmsmac-obtain-more-btcoex-related-details.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-brcmsmac-obtain-more-btcoex-related-details.patch"

>From 1389fc3ce6787af145d0851ba5a4931bd8d72b23 Mon Sep 17 00:00:00 2001
From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Sat, 29 Nov 2014 16:31:44 +0100
Subject: [PATCH] brcmsmac: obtain more btcoex related details

Added initial btcoex module for supporting bcm4313 combo chips. For
now it just detects the btcoex support and flavours.

Signed-off-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmsmac/Makefile   |   1 +
 drivers/net/wireless/brcm80211/brcmsmac/btcoex.c   | 114 +++++++++++++++++++++
 drivers/net/wireless/brcm80211/brcmsmac/btcoex.h   |  25 +++++
 drivers/net/wireless/brcm80211/brcmsmac/d11.h      |   2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   5 +
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |   1 +
 drivers/net/wireless/brcm80211/brcmsmac/types.h    |   3 +-
 .../net/wireless/brcm80211/include/chipcommon.h    |   2 +
 8 files changed, 151 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/btcoex.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/btcoex.h

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/Makefile b/drivers/net/wireless/brcm80211/brcmsmac/Makefile
index 32464ac..aa341bb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/Makefile
+++ b/drivers/net/wireless/brcm80211/brcmsmac/Makefile
@@ -26,6 +26,7 @@ brcmsmac-y := \
 	ucode_loader.o \
 	ampdu.o \
 	antsel.o \
+	btcoex.o \
 	channel.o \
 	main.o \
 	phy_shim.o \
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/btcoex.c b/drivers/net/wireless/brcm80211/brcmsmac/btcoex.c
new file mode 100644
index 0000000..01cd10d
--- /dev/null
+++ b/drivers/net/wireless/brcm80211/brcmsmac/btcoex.c
@@ -0,0 +1,114 @@
+/*
+ * Copyright (c) 2014 Broadcom Corporation
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
+ * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
+ * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/types.h>
+#include <net/mac80211.h>
+
+#include <chipcommon.h>
+#include "types.h"
+#include "debug.h"
+#include "btcoex.h"
+#include "main.h"
+
+struct brcms_btcoex {
+	struct brcms_hardware *hw;
+};
+
+static bool brcms_btc_ecicoex_enab(struct brcms_hardware *wlc_hw)
+{
+	struct bcma_bus *bus;
+	bool enab;
+
+	enab = brcms_btc_ecicoex_enab(wlc_hw);
+	if (!enab)
+		return false;
+
+	bus = wlc_hw->d11core->bus;
+	enab = D11REV_GE(wlc_hw->corerev, 15) &&
+	       (bus->drv_cc.capabilities & CC_CAP_ECI) &&
+	       (wlc_hw->machwcap & MCAP_BTCX) &&
+	       (wlc_hw->boardflags & BFL_BTCOEX) &&
+	       (wlc_hw->boardflags2 & BFL2_LEGACY) &&
+	       !(bus->drv_cc.capabilities_ext & CC_CAP2_SECI);
+
+	return enab;
+}
+
+static bool brcms_btc_secicoex_enab(struct brcms_hardware *wlc_hw)
+{
+	struct bcma_bus *bus;
+	bool enab;
+
+	bus = wlc_hw->d11core->bus;
+	enab = (wlc_hw->boardflags & BFL_BTCOEX) &&
+	       (wlc_hw->boardflags2 & BFL2_LEGACY) &&
+	       (bus->drv_cc.capabilities_ext & CC_CAP2_SECI) &&
+	       (wlc_hw->machwcap & MCAP_BTCX);
+
+	return enab;
+}
+
+static bool brcms_btc_gcicoex_enab(struct brcms_hardware *wlc_hw)
+{
+	struct bcma_bus *bus;
+	bool enab;
+
+	bus = wlc_hw->d11core->bus;
+	enab = (wlc_hw->boardflags & BFL_BTCOEX) &&
+	       (wlc_hw->boardflags2 & BFL2_LEGACY) &&
+	       (bus->drv_cc.capabilities_ext & CC_CAP_EXT_GCI_PRESENT) &&
+	       (wlc_hw->machwcap & MCAP_BTCX);
+
+	return enab;
+}
+
+static bool brcms_btc_coex_enab(struct brcms_hardware *wlc_hw)
+{
+	bool enab;
+
+	enab = brcms_btc_ecicoex_enab(wlc_hw) ||
+	       brcms_btc_secicoex_enab(wlc_hw) ||
+	       brcms_btc_gcicoex_enab(wlc_hw);
+
+	return enab;
+}
+
+struct brcms_btcoex *brcms_btcoex_attach(struct brcms_hardware *wlc_hw)
+{
+	struct brcms_btcoex *btc;
+
+	if (!brcms_btc_coex_enab(wlc_hw)) {
+		brcms_err(wlc_hw->d11core, "no btcoex supported\n");
+		return NULL;
+	}
+	btc = kzalloc(sizeof(*btc), GFP_KERNEL);
+	if (!btc)
+		return NULL;
+
+	btc->hw = wlc_hw;
+
+	brcms_err(wlc_hw->d11core, "hardware:%s%s%s\n",
+		  brcms_btc_ecicoex_enab(wlc_hw) ? " ECI" : "",
+		  brcms_btc_secicoex_enab(wlc_hw) ? " SECI" : "",
+		  brcms_btc_gcicoex_enab(wlc_hw) ? " GCI" : "");
+
+	return btc;
+}
+
+void brcms_btcoex_detach(struct brcms_btcoex *btc)
+{
+	kfree(btc);
+}
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/btcoex.h b/drivers/net/wireless/brcm80211/brcmsmac/btcoex.h
new file mode 100644
index 0000000..92032d8
--- /dev/null
+++ b/drivers/net/wireless/brcm80211/brcmsmac/btcoex.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2014 Broadcom Corporation
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
+ * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
+ * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+#ifndef _BRCMS_BTCOEX_H_
+#define _BRCMS_BTCOEX_H_
+
+struct brcms_btcoex;
+
+struct brcms_btcoex *brcms_btcoex_attach(struct brcms_hardware *wlc_hw);
+void brcms_btcoex_detach(struct brcms_btcoex *btc);
+
+#endif /* _BRCMS_BTCOEX_H_ */
+
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/d11.h b/drivers/net/wireless/brcm80211/brcmsmac/d11.h
index 9035cc4..a4754f8 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/d11.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/d11.h
@@ -548,7 +548,7 @@ struct d11regs {
 /* Mac capabilities registers */
 /*== machwcap ==*/
 #define	MCAP_TKIPMIC		0x80000000	/* TKIP MIC hardware present */
-
+#define MCAP_BTCX               0x20000000      /* BT coex hardware present */
 /*== pmqhost data ==*/
 /* data entry of head pmq entry */
 #define	PMQH_DATA_MASK		0xffff0000
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index bc9be78..fbb8b83 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -33,6 +33,7 @@
 #include "ampdu.h"
 #include "mac80211_if.h"
 #include "ucode_loader.h"
+#include "btcoex.h"
 #include "main.h"
 #include "soc.h"
 #include "dma.h"
@@ -4665,6 +4666,8 @@ static int brcms_b_attach(struct brcms_c_info *wlc, struct bcma_device *core,
 		}
 	}
 
+	wlc_hw->btc = brcms_btcoex_attach(wlc_hw);
+
 	/* disable core to match driver "down" state */
 	brcms_c_coredisable(wlc_hw);
 
@@ -4856,6 +4859,8 @@ static void brcms_b_detach(struct brcms_c_info *wlc)
 
 	wlc_phy_shim_detach(wlc_hw->physhim);
 
+	brcms_btcoex_detach(wlc_hw->btc);
+
 	if (wlc_hw->sih) {
 		ai_detach(wlc_hw->sih);
 		wlc_hw->sih = NULL;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.h b/drivers/net/wireless/brcm80211/brcmsmac/main.h
index c4d135c..1089264 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.h
@@ -376,6 +376,7 @@ struct brcms_hardware {
 				 * put struct antsel_info here if more info is
 				 * needed
 				 */
+	struct brcms_btcoex *btc;
 };
 
 /*
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/types.h b/drivers/net/wireless/brcm80211/brcmsmac/types.h
index ae1f3ad..ac8e3df 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/types.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/types.h
@@ -26,7 +26,8 @@
 #define WL_CHAN_FREQ_RANGE_5GH     3
 
 /* boardflags */
-
+/* Board supports BTCOEX */
+#define BFL_BTCOEX		0x00000001
 /* Board has gpio 9 controlling the PA */
 #define	BFL_PACTRL		0x00000002
 /* Not ok to power down the chip pll and oscillator */
diff --git a/drivers/net/wireless/brcm80211/include/chipcommon.h b/drivers/net/wireless/brcm80211/include/chipcommon.h
index d242333..d2d424c 100644
--- a/drivers/net/wireless/brcm80211/include/chipcommon.h
+++ b/drivers/net/wireless/brcm80211/include/chipcommon.h
@@ -254,6 +254,7 @@ struct chipcregs {
 #define CC_CAP_ROM		0x00800000	/* Internal boot rom active */
 #define CC_CAP_BKPLN64		0x08000000	/* 64-bit backplane */
 #define	CC_CAP_PMU		0x10000000	/* PMU Present, rev >= 20 */
+#define CC_CAP_ECI              0x20000000      /* ECI Present, rev >= 21 */
 #define	CC_CAP_SROM		0x40000000	/* Srom Present, rev >= 32 */
 /* Nand flash present, rev >= 35 */
 #define	CC_CAP_NFLASH		0x80000000
@@ -261,6 +262,7 @@ struct chipcregs {
 #define	CC_CAP2_SECI		0x00000001	/* SECI Present, rev >= 36 */
 /* GSIO (spi/i2c) present, rev >= 37 */
 #define	CC_CAP2_GSIO		0x00000002
+#define CC_CAP_EXT_GCI_PRESENT  0x00000004    /* GCI present */
 
 /* pmucapabilities */
 #define PCAP_REV_MASK	0x000000ff
-- 
1.9.1


--------------030701070605020304000106--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
