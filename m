From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] net: Allow csum_add to be provided in arch
Date: Mon, 07 Apr 2014 13:06:20 -0400 (EDT)
Message-ID: <20140407.130620.2069601044282998492.davem@davemloft.net>
References: <alpine.DEB.2.02.1404041714560.20552@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaDGRGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:06:22 -0400
In-Reply-To: <alpine.DEB.2.02.1404041714560.20552@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 4 Apr 2014 17:26:46 -0700 (PDT)

> csum_add is really nothing more then add-with-carry which
> can be implemented efficiently in some architectures.
> Allow architecture to define this protected by HAVE_ARCH_CSUM_ADD.
> 
> Provide csum_add in for x86.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

The Sparc version looks like this, feel free to integrate it into this
patch.

diff --git a/arch/sparc/include/asm/checksum_32.h b/arch/sparc/include/asm/checksum_32.h
index bdbda14..3297436 100644
--- a/arch/sparc/include/asm/checksum_32.h
+++ b/arch/sparc/include/asm/checksum_32.h
@@ -238,4 +238,15 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 	return csum_fold(csum_partial(buff, len, 0));
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	__asm__ __volatile__(
+"	addcc	%0, %1, %0\n"
+"	addx	%0, %%g0, %0"
+	: "=r" (csum)
+	: "r" (addend), "0" (csum));
+	return csum;
+}
+
 #endif /* !(__SPARC_CHECKSUM_H) */
diff --git a/arch/sparc/include/asm/checksum_64.h b/arch/sparc/include/asm/checksum_64.h
index 019b961..38b24a3 100644
--- a/arch/sparc/include/asm/checksum_64.h
+++ b/arch/sparc/include/asm/checksum_64.h
@@ -164,4 +164,15 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 	return csum_fold(csum_partial(buff, len, 0));
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	__asm__ __volatile__(
+"	addcc	%0, %1, %0\n"
+"	addc	%0, %%g0, %0"
+	: "=r" (csum)
+	: "r" (addend), "0" (csum));
+	return csum;
+}
+
 #endif /* !(__SPARC64_CHECKSUM_H) */
