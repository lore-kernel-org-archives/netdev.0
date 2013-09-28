From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH v2 1/2] powerpc: net: filter: fix DIVWU instruction opcode
Date: Sat, 28 Sep 2013 10:22:00 +0200
Message-ID: <1380356521-3432-1-git-send-email-murzin.v@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, paulus@samba.org, matt@ozlabs.org,
	edumazet@google.com, dborkman@redhat.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:44680 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab3I1IW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 04:22:56 -0400
Received: by mail-lb0-f175.google.com with SMTP id y6so2949927lbh.6
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 01:22:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently DIVWU stands for *signed* divw opcode:

7d 2a 4b 96 	divwu   r9,r10,r9
7d 2a 4b d6 	divw    r9,r10,r9

Use the *unsigned* divw opcode for DIVWU.

Suggested-by: Vassili Karpov <av1474@comtv.ru>
Reviewed-by: Vassili Karpov <av1474@comtv.ru>
Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
Acked-by: Matt Evans <matt@ozlabs.org>
---
Changelog

v1->v2

Added credit to Vassili Karpov (malc) who kindly reviewed generated assembly
[1] and highlighted usage of signed division.
Note: temporary, for technical reason, he's not able to receive email.

[1]http://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg71635.html

 arch/powerpc/include/asm/ppc-opcode.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index eccfc16..0a4a683 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -171,7 +171,7 @@
 #define PPC_INST_MULLW			0x7c0001d6
 #define PPC_INST_MULHWU			0x7c000016
 #define PPC_INST_MULLI			0x1c000000
-#define PPC_INST_DIVWU			0x7c0003d6
+#define PPC_INST_DIVWU			0x7c000396
 #define PPC_INST_RLWINM			0x54000000
 #define PPC_INST_RLDICR			0x78000004
 #define PPC_INST_SLW			0x7c000030
-- 
1.8.1.5
