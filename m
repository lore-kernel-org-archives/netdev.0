From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] arch/powerpc: Update parameters for csum_tcpudp_magic & csum_tcpudp_nofold
Date: Thu, 27 Oct 2016 16:30:06 +0200
Message-ID: <1477578606-27562-1-git-send-email-ivecera@redhat.com>
Cc: Alexander Duyck <aduyck@mirantis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942928AbcJ0OaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 10:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 01cfbad "ipv4: Update parameters for csum_tcpudp_magic to their
original types" changed parameters for csum_tcpudp_magic and
csum_tcpudp_nofold for many platforms but not for PowerPC.

Fixes: 01cfbad "ipv4: Update parameters for csum_tcpudp_magic to their original types"
Cc: Alexander Duyck <aduyck@mirantis.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 arch/powerpc/include/asm/checksum.h | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
index ee655ed..1e8fceb 100644
--- a/arch/powerpc/include/asm/checksum.h
+++ b/arch/powerpc/include/asm/checksum.h
@@ -53,10 +53,8 @@ static inline __sum16 csum_fold(__wsum sum)
 	return (__force __sum16)(~((__force u32)sum + tmp) >> 16);
 }
 
-static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-                                     unsigned short len,
-                                     unsigned short proto,
-                                     __wsum sum)
+static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+					__u8 proto, __wsum sum)
 {
 #ifdef __powerpc64__
 	unsigned long s = (__force u32)sum;
@@ -83,10 +81,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * computes the checksum of the TCP/UDP pseudo-header
  * returns a 16-bit checksum, already complemented
  */
-static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
-					__wsum sum)
+static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+					__u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
-- 
2.7.3
