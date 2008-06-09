From: Ingo Molnar <mingo@elte.hu>
Subject: [patch, v2.6.26-rc5] net/irda build fix: mcs7780
Date: Mon, 9 Jun 2008 10:22:57 +0200
Message-ID: <20080609082257.GA15282@elte.hu>
References: <20080604.170123.234927220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:59712 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840AbYFIIXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 04:23:06 -0400
Content-Disposition: inline
In-Reply-To: <20080604.170123.234927220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-tip testing found the following build error:

  drivers/built-in.o: In function `mcs_receive_irq':
  mcs7780.c:(.text+0x4e429): undefined reference to `crc32_le'
  drivers/built-in.o: In function `mcs_hard_xmit':
  mcs7780.c:(.text+0x4e9af): undefined reference to `crc32_le'

with:

  http://redhat.com/~mingo/misc/config-Sun_Jun__8_22_56_14_CEST_2008.bad

the reason is a missing enablement of the CRC32 library in the Kconfig.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/irda/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: linux/drivers/net/irda/Kconfig
===================================================================
--- linux.orig/drivers/net/irda/Kconfig
+++ linux/drivers/net/irda/Kconfig
@@ -329,6 +329,7 @@ config PXA_FICP
 config MCS_FIR
 	tristate "MosChip MCS7780 IrDA-USB dongle"
 	depends on IRDA && USB && EXPERIMENTAL
+	select CRC32
 	help
 	  Say Y or M here if you want to build support for the MosChip
 	  MCS7780 IrDA-USB bridge device driver.
