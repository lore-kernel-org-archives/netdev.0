From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/4] UAPI: Fix compilation of the wanxl firmware blob.
Date: Wed, 07 Nov 2012 12:37:09 +0000
Message-ID: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244Ab2KGMh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 07:37:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wanxl firmware needs access to some bits of UAPI stuff, so the -I flag in
the Makefile needs adjusting to point at the UAPI headers.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/wan/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index eac709b..4dac96b 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -52,7 +52,7 @@ endif
 
 quiet_cmd_build_wanxlfw = BLD FW  $@
       cmd_build_wanxlfw = \
-	$(CPP) -Wp,-MD,$(depfile) -I$(srctree)/include $< | $(AS68K) -m68360 -o $(obj)/wanxlfw.o; \
+	$(CPP) -Wp,-MD,$(depfile) -I$(srctree)/include/uapi $< | $(AS68K) -m68360 -o $(obj)/wanxlfw.o; \
 	$(LD68K) --oformat binary -Ttext 0x1000 $(obj)/wanxlfw.o -o $(obj)/wanxlfw.bin; \
 	hexdump -ve '"\n" 16/1 "0x%02X,"' $(obj)/wanxlfw.bin | sed 's/0x  ,//g;1s/^/static u8 firmware[]={/;$$s/,$$/\n};\n/' >$(obj)/wanxlfw.inc; \
 	rm -f $(obj)/wanxlfw.bin $(obj)/wanxlfw.o
