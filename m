From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] net/wan/sbni: fix section usage
Date: Wed, 2 Mar 2005 10:12:44 -0800
Message-ID: <20050302101244.4499d97c.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, torvalds <torvalds@osdl.org>,
        akpm
 <akpm@osdl.org>
To: timofeev@granch.ru, jgarzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


net/wan/sbni data reference can be initdata:

Error: ./drivers/net/wan/sbni.o .data refers to 0000000000000000 R_X86_64_64       .init.data+0x0000000000000060
Error: ./drivers/net/wan/sbni.o .data refers to 0000000000000008 R_X86_64_64       .init.data+0x0000000000000140
Error: ./drivers/net/wan/sbni.o .data refers to 0000000000000010 R_X86_64_64       .init.data+0x0000000000000180
Error: ./drivers/net/wan/sbni.o .data refers to 0000000000000018 R_X86_64_64       .init.data+0x0000000000000020
Error: ./drivers/net/wan/sbni.o .data refers to 0000000000000020 R_X86_64_64       .init.data+0x00000000000001c0

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/wan/sbni.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/wan/sbni.c~wan_sbni_sections ./drivers/net/wan/sbni.c
--- ./drivers/net/wan/sbni.c~wan_sbni_sections	2005-02-27 12:54:05.851033952 -0800
+++ ./drivers/net/wan/sbni.c	2005-03-02 09:45:09.156084080 -0800
@@ -176,7 +176,7 @@ static u32	mac[  SBNI_MAX_NUM_CARDS ] __
 
 #ifndef MODULE
 typedef u32  iarr[];
-static iarr  *dest[5] = { &io, &irq, &baud, &rxl, &mac };
+static iarr __initdata *dest[5] = { &io, &irq, &baud, &rxl, &mac };
 #endif
 
 /* A zero-terminated list of I/O addresses to be probed on ISA bus */


---
