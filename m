From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 2/9] powerpc: mark xer clobbered in csum_add()
Date: Tue, 22 Sep 2015 16:34:21 +0200 (CEST)
Message-ID: <14f0f70d1e59f423f58705d2c6ba971373f45481.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.236.17.93.rev.sfr.net ([93.17.236.2]:23835 "EHLO
	mailhub1.si.c-s.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758154AbbIVOe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 10:34:26 -0400
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addc uses carry so xer is clobbered in csum_add()

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/checksum.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
index e8d9ef4..d2ca07b 100644
--- a/arch/powerpc/include/asm/checksum.h
+++ b/arch/powerpc/include/asm/checksum.h
@@ -141,7 +141,7 @@ static inline __wsum csum_add(__wsum csum, __wsum addend)
 #else
 	asm("addc %0,%0,%1;"
 	    "addze %0,%0;"
-	    : "+r" (csum) : "r" (addend));
+	    : "+r" (csum) : "r" (addend) : "xer");
 	return csum;
 #endif
 }
-- 
2.1.0
