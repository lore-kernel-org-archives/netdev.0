From: akpm@osdl.org
Subject: [patch 18/18] gcc-3.5: tg3.c warnings
Date: Sun, 25 Jan 2004 03:08:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251108.i0PB8Qo25199@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



drivers/net/tg3.c: In function `tg3_get_regs':                                  drivers/net/tg3.c:5884: warning: use of cast expressions as lvalues is deprecated                                                                               drivers/net/tg3.c:5885: warning: use of cast expressions as lvalues is deprecated                                                                               drivers/net/tg3.c:5886: warning: use of cast expressions as lvalues is deprecated                                                                               drivers/net/tg3.c:5887: warning: use of cast expressions as lvalues is deprecated                                                                               drivers/net/tg3.c:5888: warning: use of cast expressions as lvalues is deprecated                                                                               


---

 drivers/net/tg3.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff -puN drivers/net/tg3.c~gcc-35-tg3 drivers/net/tg3.c
--- 25/drivers/net/tg3.c~gcc-35-tg3	2004-01-25 03:01:48.000000000 -0800
+++ 25-akpm/drivers/net/tg3.c	2004-01-25 03:01:48.000000000 -0800
@@ -5850,10 +5850,12 @@ static int tg3_get_regs_len(struct net_d
 	return TG3_REGDUMP_LEN;
 }
 
-static void tg3_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
+static void tg3_get_regs(struct net_device *dev,
+		struct ethtool_regs *regs, void *_p)
 {
+	u32 *p = _p;
 	struct tg3 *tp = dev->priv;
-	u8 *orig_p = p;
+	u8 *orig_p = _p;
 	int i;
 
 	regs->version = 0;
@@ -5863,15 +5865,15 @@ static void tg3_get_regs(struct net_devi
 	spin_lock_irq(&tp->lock);
 	spin_lock(&tp->tx_lock);
 
-#define __GET_REG32(reg)	(*((u32 *)(p))++ = tr32(reg))
+#define __GET_REG32(reg)	(*(p)++ = tr32(reg))
 #define GET_REG32_LOOP(base,len)		\
-do {	p = orig_p + (base);			\
+do {	p = (u32 *)(orig_p + (base));		\
 	for (i = 0; i < len; i += 4)		\
 		__GET_REG32((base) + i);	\
 } while (0)
-#define GET_REG32_1(reg)	\
-do {	p = orig_p + (reg);	\
-	__GET_REG32((reg));	\
+#define GET_REG32_1(reg)			\
+do {	p = (u32 *)(orig_p + (reg));		\
+	__GET_REG32((reg));			\
 } while (0)
 
 	GET_REG32_LOOP(TG3PCI_VENDOR, 0xb0);

_
