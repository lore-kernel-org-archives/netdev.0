From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/4] Make the wanxl firmware array const
Date: Wed, 07 Nov 2012 12:37:31 +0000
Message-ID: <20121107123731.4147.57657.stgit@warthog.procyon.org.uk>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987Ab2KGMhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 07:37:38 -0500
In-Reply-To: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the wanxl firmware array const so that it goes in the read-only section.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/wan/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index b0a6163..df70248 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -54,7 +54,7 @@ quiet_cmd_build_wanxlfw = BLD FW  $@
       cmd_build_wanxlfw = \
 	$(CPP) -D__ASSEMBLY__ -Wp,-MD,$(depfile) -I$(srctree)/include/uapi $< | $(AS68K) -m68360 -o $(obj)/wanxlfw.o; \
 	$(LD68K) --oformat binary -Ttext 0x1000 $(obj)/wanxlfw.o -o $(obj)/wanxlfw.bin; \
-	hexdump -ve '"\n" 16/1 "0x%02X,"' $(obj)/wanxlfw.bin | sed 's/0x  ,//g;1s/^/static u8 firmware[]={/;$$s/,$$/\n};\n/' >$(obj)/wanxlfw.inc; \
+	hexdump -ve '"\n" 16/1 "0x%02X,"' $(obj)/wanxlfw.bin | sed 's/0x  ,//g;1s/^/static const u8 firmware[]={/;$$s/,$$/\n};\n/' >$(obj)/wanxlfw.inc; \
 	rm -f $(obj)/wanxlfw.bin $(obj)/wanxlfw.o
 
 $(obj)/wanxlfw.inc:	$(src)/wanxlfw.S
