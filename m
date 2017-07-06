From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] ptp: dte: Use LL suffix for 64-bit constants
Date: Thu,  6 Jul 2017 10:34:54 +0200
Message-ID: <1499330094-24423-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Arun Parameswaran <arun.parameswaran@broadcom.com>,
        Richard Cochran <richardcochran@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With gcc 4.1.2:

    drivers/ptp/ptp_dte.c: In function ‘dte_write_nco_delta’:
    drivers/ptp/ptp_dte.c:105: warning: integer constant is too large for ‘long’ type
    drivers/ptp/ptp_dte.c:112: warning: integer constant is too large for ‘long’ type
    drivers/ptp/ptp_dte.c:114: warning: integer constant is too large for ‘long’ type

Add the missing "LL" suffix to fix this.

Fixes: 8a56aa107f1e8123 ("ptp: Add a ptp clock driver for Broadcom DTE")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/ptp/ptp_dte.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ptp/ptp_dte.c b/drivers/ptp/ptp_dte.c
index 00145a3f1e707451..faf6f7a837137408 100644
--- a/drivers/ptp/ptp_dte.c
+++ b/drivers/ptp/ptp_dte.c
@@ -40,7 +40,7 @@
 #define DTE_WRAP_AROUND_NSEC_SHIFT 44
 
 /* 44 bits NCO */
-#define DTE_NCO_MAX_NS	0xFFFFFFFFFFF
+#define DTE_NCO_MAX_NS	0xFFFFFFFFFFFLL
 
 /* 125MHz with 3.29 reg cfg */
 #define DTE_PPB_ADJ(ppb) (u32)(div64_u64((((u64)abs(ppb) * BIT(28)) +\
-- 
2.7.4
