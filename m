From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: [PATCH] smc91x SuperH support
Date: Thu, 3 May 2007 18:56:56 +0900
Message-ID: <20070503185656.88529e01.iwamatsu@nigauri.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, iwamatsu@nigauri.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from l247104.ppp.asahi-net.or.jp ([218.219.247.104]:32975 "EHLO
	ns.nigauri.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031072AbXECKQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 06:16:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all.

This patch supports SuperH of smc91x. 
smc91x installed on the board of SuperH comes to work by applying this patch. 
Please apply this patch .

regards,
 Nobuhiro

-- 
Nobuhiro Iwamatsu
	E-Mail : hemamu@t-base.ne.jp
	GPG ID : 3170EBE9 

Signed-off-by:	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

--- a/drivers/net/smc91x.h	2007-05-03 18:47:19.000000000 +0900
+++ b/drivers/net/smc91x.h	2007-05-03 18:48:59.000000000 +0900
@@ -232,6 +232,40 @@
 #define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
 
+#elif   defined(CONFIG_SUPERH)
+
+#if defined(CONFIG_SH_7780_SOLUTION_ENGINE) || defined(CONFIG_SH_7722_SOLUTION_ENGINE)
+#define SMC_CAN_USE_8BIT       0
+#define SMC_CAN_USE_16BIT      1
+#define SMC_CAN_USE_32BIT      0
+#define SMC_IO_SHIFT           0
+#define SMC_NOWAIT             1
+
+#define SMC_inb(a, r)          (inw((a) + ((r)&~1)) >> (8*(r%2)))&0xff
+#define SMC_inw(a, r)          inw((a) + (r))
+#define SMC_outb(v, a, r)      outw(((inw((a)+((r)&~1))*(0xff<<8*(r%2)))) | ((v)<<(8*(r&2)))), (a) + ((r)&~1))
+
+#define SMC_outw(v, a, r)      outw(v, (a) + (r))
+#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
+
+#else /* BOARDS */
+
+#define SMC_CAN_USE_8BIT       1
+#define SMC_CAN_USE_16BIT      1
+#define SMC_CAN_USE_32BIT      1
+
+#define SMC_inb(a, r)          inb((a) + (r))
+#define SMC_inw(a, r)          inw((a) + (r))
+#define SMC_outb(v, a, r)      outb(v, (a) + (r))
+#define SMC_outw(v, a, r)      outw(v, (a) + (r))
+#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
+
+#endif  /* BOARDS */
+
+#define set_irq_type(irq, type) do {} while (0)
+
 #elif   defined(CONFIG_M32R)
 
 #define SMC_CAN_USE_8BIT	0
