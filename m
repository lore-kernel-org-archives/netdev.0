From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/8 v3] net: Allow csum_add to be provided in arch
Date: Tue, 29 Apr 2014 09:17:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290858490.8886@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:34907 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933447AbaD2QRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:17:45 -0400
Received: by mail-yh0-f73.google.com with SMTP id b6so60719yha.2
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:17:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

csum_add is really nothing more then add-with-carry which
can be implemented efficiently in some architectures.
Allow architecture to define this protected by HAVE_ARCH_CSUM_ADD.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/checksum.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index a28f4e0..87cb190 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -57,12 +57,14 @@ static __inline__ __wsum csum_and_copy_to_user
 }
 #endif
 
+#ifndef HAVE_ARCH_CSUM_ADD
 static inline __wsum csum_add(__wsum csum, __wsum addend)
 {
 	u32 res = (__force u32)csum;
 	res += (__force u32)addend;
 	return (__force __wsum)(res + (res < (__force u32)addend));
 }
+#endif
 
 static inline __wsum csum_sub(__wsum csum, __wsum addend)
 {
-- 
1.9.1.423.g4596e3a
