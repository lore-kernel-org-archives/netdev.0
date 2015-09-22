From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 8/9] powerpc: simplify csum_add(a, b) in case a or b is
 constant 0
Date: Tue, 22 Sep 2015 16:34:34 +0200 (CEST)
Message-ID: <5549ecca2c921f34d076c47b5e2a91a3e78b20a7.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify csum_add(a, b) in case a or b is constant 0

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/checksum.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
index 56deea8..f8a9704 100644
--- a/arch/powerpc/include/asm/checksum.h
+++ b/arch/powerpc/include/asm/checksum.h
@@ -119,7 +119,13 @@ static inline __wsum csum_add(__wsum csum, __wsum addend)
 {
 #ifdef __powerpc64__
 	u64 res = (__force u64)csum;
+#endif
+	if (__builtin_constant_p(csum) && csum == 0)
+		return addend;
+	if (__builtin_constant_p(addend) && addend == 0)
+		return csum;
 
+#ifdef __powerpc64__
 	res += (__force u64)addend;
 	return (__force __wsum)((u32)res + (res >> 32));
 #else
-- 
2.1.0
