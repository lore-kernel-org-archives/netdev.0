From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] mISDN: mark symbols static where possible
Date: Mon, 29 Aug 2016 19:49:15 +0800
Message-ID: <1472471355-30191-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 12 warnings when biuld kernel with W=1:
drivers/isdn/hardware/mISDN/hfcmulti.c:568:1: warning: no previous declaration for 'enablepcibridge' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:574:1: warning: no previous declaration for 'disablepcibridge' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:580:1: warning: no previous declaration for 'readpcibridge' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:608:1: warning: no previous declaration for 'writepcibridge' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:638:1: warning: no previous declaration for 'cpld_set_reg' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:645:1: warning: no previous declaration for 'cpld_write_reg' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:657:1: warning: no previous declaration for 'cpld_read_reg' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:674:1: warning: no previous declaration for 'vpm_write_address' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:681:1: warning: no previous declaration for 'vpm_read_address' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:695:1: warning: no previous declaration for 'vpm_in' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:716:1: warning: no previous declaration for 'vpm_out' [-Wmissing-declarations]
drivers/isdn/hardware/mISDN/hfcmulti.c:1028:1: warning: no previous declaration for 'plxsd_checksync' [-Wmissing-declarations]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 28543d7..480c2d7 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -564,19 +564,19 @@ disable_hwirq(struct hfc_multi *hc)
 #define	MAX_TDM_CHAN 32
 
 
-inline void
+static inline void
 enablepcibridge(struct hfc_multi *c)
 {
 	HFC_outb(c, R_BRG_PCM_CFG, (0x0 << 6) | 0x3); /* was _io before */
 }
 
-inline void
+static inline void
 disablepcibridge(struct hfc_multi *c)
 {
 	HFC_outb(c, R_BRG_PCM_CFG, (0x0 << 6) | 0x2); /* was _io before */
 }
 
-inline unsigned char
+static inline unsigned char
 readpcibridge(struct hfc_multi *hc, unsigned char address)
 {
 	unsigned short cipv;
@@ -604,7 +604,7 @@ readpcibridge(struct hfc_multi *hc, unsigned char address)
 	return data;
 }
 
-inline void
+static inline void
 writepcibridge(struct hfc_multi *hc, unsigned char address, unsigned char data)
 {
 	unsigned short cipv;
@@ -634,14 +634,14 @@ writepcibridge(struct hfc_multi *hc, unsigned char address, unsigned char data)
 	outl(datav, hc->pci_iobase);
 }
 
-inline void
+static inline void
 cpld_set_reg(struct hfc_multi *hc, unsigned char reg)
 {
 	/* Do data pin read low byte */
 	HFC_outb(hc, R_GPIO_OUT1, reg);
 }
 
-inline void
+static inline void
 cpld_write_reg(struct hfc_multi *hc, unsigned char reg, unsigned char val)
 {
 	cpld_set_reg(hc, reg);
@@ -653,7 +653,7 @@ cpld_write_reg(struct hfc_multi *hc, unsigned char reg, unsigned char val)
 	return;
 }
 
-inline unsigned char
+static inline unsigned char
 cpld_read_reg(struct hfc_multi *hc, unsigned char reg)
 {
 	unsigned char bytein;
@@ -670,14 +670,14 @@ cpld_read_reg(struct hfc_multi *hc, unsigned char reg)
 	return bytein;
 }
 
-inline void
+static inline void
 vpm_write_address(struct hfc_multi *hc, unsigned short addr)
 {
 	cpld_write_reg(hc, 0, 0xff & addr);
 	cpld_write_reg(hc, 1, 0x01 & (addr >> 8));
 }
 
-inline unsigned short
+static inline unsigned short
 vpm_read_address(struct hfc_multi *c)
 {
 	unsigned short addr;
@@ -691,7 +691,7 @@ vpm_read_address(struct hfc_multi *c)
 	return addr & 0x1ff;
 }
 
-inline unsigned char
+static inline unsigned char
 vpm_in(struct hfc_multi *c, int which, unsigned short addr)
 {
 	unsigned char res;
@@ -712,7 +712,7 @@ vpm_in(struct hfc_multi *c, int which, unsigned short addr)
 	return res;
 }
 
-inline void
+static inline void
 vpm_out(struct hfc_multi *c, int which, unsigned short addr,
 	unsigned char data)
 {
@@ -1024,7 +1024,7 @@ hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 }
 
 /* This must be called AND hc must be locked irqsave!!! */
-inline void
+static inline void
 plxsd_checksync(struct hfc_multi *hc, int rm)
 {
 	if (hc->syncronized) {
-- 
2.7.4
