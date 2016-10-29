From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH 1/4] isdn/eicon: remove unused argument in DBG_ERR call
Date: Sat, 29 Oct 2016 14:56:02 +0200
Message-ID: <20161029125605.13610-1-nicolas.iooss_linux@m4x.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diva_um_idi_read() can call DBG_ERR with 3 format arguments but using a
format string which only uses 2 of them. Remove the last one.

This bug has been found by adding a __printf attribute to
myDbgPrint_...() functions. As this addition leads the compiler to
report a lot of -Wformat warnings (for example the compiler complains
when "%08x" is used to format a pointer, as it is done with all usages
of "E(%08x)" in um_idi.c), this patch does not add any __printf
attribute.

This patch has only been compile-tested.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
---
 drivers/isdn/hardware/eicon/um_idi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/um_idi.c b/drivers/isdn/hardware/eicon/um_idi.c
index e1519718ce67..13ef38fa6cb0 100644
--- a/drivers/isdn/hardware/eicon/um_idi.c
+++ b/drivers/isdn/hardware/eicon/um_idi.c
@@ -351,7 +351,7 @@ int diva_um_idi_read(void *entity,
 			  Not enough space to read message
 			*/
 			DBG_ERR(("A: A(%d) E(%08x) read small buffer",
-				 a->adapter_nr, e, ret));
+				 a->adapter_nr, e));
 			diva_os_leave_spin_lock(&adapter_lock, &old_irql,
 						"read");
 			return (-2);
-- 
2.10.1
