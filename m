From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] net: sh_eth: Fix build by forgot including linux/interrupt.h
Date: Wed, 10 Aug 2011 15:15:50 +0900
Message-ID: <1312956950-32598-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: adobriyan@gmail.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:38952 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab1HJGQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 02:16:26 -0400
Received: by gwaa12 with SMTP id a12so480419gwa.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 23:16:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By a6b7a407865aab9f849dd99a71072b7cd1175116, remove interrupt.h
from netdevice.h. But this forget to revise sh_eth.

This fix the build failure.

error: expected '=', ',', ';', 'asm' or '__attribute__' before 'sh_eth_interrupt'
error: implicit declaration of function 'request_irq'
error: 'sh_eth_interrupt' undeclared (first use in this function)
error: (Each undeclared identifier is reported only once
	drivers/net/sh_eth.c:1386: error: for each function it appears in.)
error: 'IRQF_SHARED' undeclared (first use in this function)
error: implicit declaration of function 'free_irq'

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
CC: Alexey Dobriyan <adobriyan@gmail.com>
---
 drivers/net/sh_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index ad35c21..190f619 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -21,6 +21,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
-- 
1.7.5.4

