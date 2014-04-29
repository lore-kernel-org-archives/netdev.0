From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/8 v3] x86_64: csum_add for x86_64
Date: Tue, 29 Apr 2014 09:17:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290859190.9012@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:62332 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933392AbaD2QR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:17:58 -0400
Received: by mail-qc0-f201.google.com with SMTP id c9so60222qcz.2
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:17:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add csum_add function for x86_64.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 arch/x86/include/asm/checksum_64.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a0..3581761 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -188,4 +188,11 @@ static inline unsigned add32_with_carry(unsigned a, unsigned b)
 	return a;
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	return (__force __wsum)add32_with_carry((__force unsigned)csum,
+						(__force unsigned)addend);
+}
+
 #endif /* _ASM_X86_CHECKSUM_64_H */
-- 
1.9.1.423.g4596e3a
