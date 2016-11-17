From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 1/5] net: gianfar_ptp: Rename FS bit to FIPERST
Date: Thu, 17 Nov 2016 11:19:10 -0800
Message-ID: <20161117191914.11077-2-f.fainelli@gmail.com>
References: <20161117191914.11077-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36187 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754156AbcKQTUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 14:20:48 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so18292082pgx.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 11:20:44 -0800 (PST)
In-Reply-To: <20161117191914.11077-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FS is a global symbol used by the x86 32-bit architecture, fixes builds
re-definitions:

>> drivers/net/ethernet/freescale/gianfar_ptp.c:75:0: warning: "FS"
>> redefined
    #define FS                    (1<<28) /* FIPER start indication */

   In file included from arch/x86/include/uapi/asm/ptrace.h:5:0,
                    from arch/x86/include/asm/ptrace.h:6,
                    from arch/x86/include/asm/math_emu.h:4,
                    from arch/x86/include/asm/processor.h:11,
                    from include/linux/mutex.h:19,
                    from include/linux/kernfs.h:13,
                    from include/linux/sysfs.h:15,
                    from include/linux/kobject.h:21,
                    from include/linux/device.h:17,
                    from
drivers/net/ethernet/freescale/gianfar_ptp.c:23:
   arch/x86/include/uapi/asm/ptrace-abi.h:15:0: note: this is the
location of the previous definition
    #define FS 9

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 57798814160d..3e8d1fffe34e 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -72,7 +72,7 @@ struct gianfar_ptp_registers {
 /* Bit definitions for the TMR_CTRL register */
 #define ALM1P                 (1<<31) /* Alarm1 output polarity */
 #define ALM2P                 (1<<30) /* Alarm2 output polarity */
-#define FS                    (1<<28) /* FIPER start indication */
+#define FIPERST               (1<<28) /* FIPER start indication */
 #define PP1L                  (1<<27) /* Fiper1 pulse loopback mode enabled. */
 #define PP2L                  (1<<26) /* Fiper2 pulse loopback mode enabled. */
 #define TCLK_PERIOD_SHIFT     (16) /* 1588 timer reference clock period. */
@@ -502,7 +502,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
 	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
 	set_alarm(etsects);
-	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FS|RTPE|TE|FRD);
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FIPERST|RTPE|TE|FRD);
 
 	spin_unlock_irqrestore(&etsects->lock, flags);
 
-- 
2.9.3
