From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: qmgr for ixp4xx
Date: Tue, 2 Dec 2008 19:44:40 +0100
Message-ID: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:62874 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbYLBSom convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 13:44:42 -0500
Received: by ug-out-1314.google.com with SMTP id 39so3144263ugf.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 10:44:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

As I am trying to use my HSSs as 4E1, I find that the FIFOs for each
HDLC should be 1 word wide and not 4 words wide. I think that this
finally means that when accessing the queues, I have to do the
following modification.

diff -urN linux-2.6.26.7_hssorig/include/asm-arm/arch-ixp4xx/qmgr.h
linux-2.6.26.7/include/asm-arm/arch-ixp4xx/qmgr.h
--- linux-2.6.26.7_hssorig/include/asm-arm/arch-ixp4xx/qmgr.h	2008-10-2=
2
23:46:18.000000000 +0200
+++ linux-2.6.26.7/include/asm-arm/arch-ixp4xx/qmgr.h	2008-12-02
10:47:23.000000000 +0100
@@ -67,16 +67,17 @@
 void qmgr_release_queue(unsigned int queue);


-static inline void qmgr_put_entry(unsigned int queue, u32 val)
+static inline void qmgr_put_entry(unsigned int queue, unsigned int pip=
e,
+                   u32 val)
 {
 	extern struct qmgr_regs __iomem *qmgr_regs;
-	__raw_writel(val, &qmgr_regs->acc[queue][0]);
+	__raw_writel(val, &qmgr_regs->acc[queue][pipe]);
 }

-static inline u32 qmgr_get_entry(unsigned int queue)
+static inline u32 qmgr_get_entry(unsigned int queue, unsigned int pipe=
)
 {
 	extern struct qmgr_regs __iomem *qmgr_regs;
-	return __raw_readl(&qmgr_regs->acc[queue][0]);
+	return __raw_readl(&qmgr_regs->acc[queue][pipe]);
 }

 static inline int qmgr_get_stat1(unsigned int queue)

Is it correct?

Thanks

Miguel =C1ngel =C1lvarez
