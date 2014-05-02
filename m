From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/8 v4] net: Change x86_64 add32_with_carry to allow memory
 operand
Date: Fri, 2 May 2014 16:28:40 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405021527550.19635@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:56158 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaEBX2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 19:28:41 -0400
Received: by mail-oa0-f73.google.com with SMTP id i4so1011130oah.0
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 16:28:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Eric Dumazet:

Note add32_with_carry(a, b) is suboptimal, as it forces
a and b in registers.

b could be a memory or a register operand.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 arch/x86/include/asm/checksum_64.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index 3581761..cd00e17 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -184,7 +184,7 @@ static inline unsigned add32_with_carry(unsigned a, unsigned b)
 	asm("addl %2,%0\n\t"
 	    "adcl $0,%0"
 	    : "=r" (a)
-	    : "0" (a), "r" (b));
+	    : "0" (a), "rm" (b));
 	return a;
 }
 
-- 
1.9.1.423.g4596e3a
