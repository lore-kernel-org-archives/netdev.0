From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/4] Fix the wanxl firmware to include missing constants
Date: Wed, 07 Nov 2012 12:37:24 +0000
Message-ID: <20121107123724.4147.98542.stgit@warthog.procyon.org.uk>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962Ab2KGMhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 07:37:33 -0500
In-Reply-To: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the wanxl firmware to include missing constants such as PARITY_NONE.  It
should be #including the linux/hdlc/ioctl.h header.

To make this work, we also have to guard parts of ioctl.h with !__ASSEMBLY__.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/wan/Makefile        |    2 +-
 drivers/net/wan/wanxlfw.S       |    1 +
 include/uapi/linux/hdlc/ioctl.h |    3 +++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 4dac96b..b0a6163 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -52,7 +52,7 @@ endif
 
 quiet_cmd_build_wanxlfw = BLD FW  $@
       cmd_build_wanxlfw = \
-	$(CPP) -Wp,-MD,$(depfile) -I$(srctree)/include/uapi $< | $(AS68K) -m68360 -o $(obj)/wanxlfw.o; \
+	$(CPP) -D__ASSEMBLY__ -Wp,-MD,$(depfile) -I$(srctree)/include/uapi $< | $(AS68K) -m68360 -o $(obj)/wanxlfw.o; \
 	$(LD68K) --oformat binary -Ttext 0x1000 $(obj)/wanxlfw.o -o $(obj)/wanxlfw.bin; \
 	hexdump -ve '"\n" 16/1 "0x%02X,"' $(obj)/wanxlfw.bin | sed 's/0x  ,//g;1s/^/static u8 firmware[]={/;$$s/,$$/\n};\n/' >$(obj)/wanxlfw.inc; \
 	rm -f $(obj)/wanxlfw.bin $(obj)/wanxlfw.o
diff --git a/drivers/net/wan/wanxlfw.S b/drivers/net/wan/wanxlfw.S
index 73aae2b..21565d5 100644
--- a/drivers/net/wan/wanxlfw.S
+++ b/drivers/net/wan/wanxlfw.S
@@ -35,6 +35,7 @@
 */
 
 #include <linux/hdlc.h>
+#include <linux/hdlc/ioctl.h>
 #include "wanxl.h"
 
 /* memory addresses and offsets */
diff --git a/include/uapi/linux/hdlc/ioctl.h b/include/uapi/linux/hdlc/ioctl.h
index 5839723..e5dbbb0 100644
--- a/include/uapi/linux/hdlc/ioctl.h
+++ b/include/uapi/linux/hdlc/ioctl.h
@@ -34,6 +34,8 @@
 #define LMI_CCITT		3 /* ITU-T Annex A */
 #define LMI_CISCO		4 /* The "original" LMI, aka Gang of Four */
 
+#ifndef __ASSEMBLY__
+
 typedef struct { 
 	unsigned int clock_rate; /* bits per second */
 	unsigned int clock_type; /* internal, external, TX-internal etc. */
@@ -78,4 +80,5 @@ typedef struct {
 
 /* PPP doesn't need any info now - supply length = 0 to ioctl */
 
+#endif /* __ASSEMBLY__ */
 #endif /* __HDLC_IOCTL_H__ */
