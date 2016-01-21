From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/irda: bfin_sir: remove duplicate defines
Date: Thu, 21 Jan 2016 10:42:31 +0530
Message-ID: <1453353151-4622-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, Steven Miao <realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The defconfig build of blackfin is failing with the error:

arch/blackfin/include/asm/bfin_serial.h:269:0: warning: "port_membase" redefined
drivers/net/irda/bfin_sir.h:85:0: note: this is the location of the previous definition
arch/blackfin/include/asm/bfin_serial.h:382:0: warning: "get_lsr_cache" redefined
drivers/net/irda/bfin_sir.h:86:0: note: this is the location of the previous definition
arch/blackfin/include/asm/bfin_serial.h:383:0: warning: "put_lsr_cache" redefined
drivers/net/irda/bfin_sir.h:87:0: note: this is the location of the previous definition

port_membase, get_lsr_cache, put_lsr_cache are already defined in the
architecture files, no need to define them again in the driver.

Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
---
 drivers/net/irda/bfin_sir.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.h b/drivers/net/irda/bfin_sir.h
index 29cbde8..d47cf14 100644
--- a/drivers/net/irda/bfin_sir.h
+++ b/drivers/net/irda/bfin_sir.h
@@ -82,9 +82,6 @@ struct bfin_sir_self {
 
 #define DRIVER_NAME "bfin_sir"
 
-#define port_membase(port)     (((struct bfin_sir_port *)(port))->membase)
-#define get_lsr_cache(port)    (((struct bfin_sir_port *)(port))->lsr)
-#define put_lsr_cache(port, v) (((struct bfin_sir_port *)(port))->lsr = (v))
 #include <asm/bfin_serial.h>
 
 static const unsigned short per[][4] = {
-- 
1.9.1
