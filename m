From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/8 v3] net: Change x86_64 add32_with_carry to allow memory
 operand
Date: Tue, 29 Apr 2014 09:18:09 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290859470.9143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:49112 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933392AbaD2QSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:18:10 -0400
Received: by mail-ob0-f201.google.com with SMTP id vb8so88560obc.4
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:18:09 -0700 (PDT)
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
