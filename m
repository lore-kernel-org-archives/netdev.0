From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/3] x86_64: Define 128-bit types for kernel code only
Date: Wed, 22 Aug 2012 02:20:21 +0100
Message-ID: <1345598421.2659.73.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<x86@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43248 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753281Ab2HVBUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 21:20:25 -0400
In-Reply-To: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These types will initially be used for 128-bit I/O operations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I'm not sure whether there is any point in all the _t type aliases, but
they're defined for all the other explicit-width types.

Ben.

 arch/x86/include/asm/types.h |    8 ++++++++
 include/linux/types.h        |   12 ++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/types.h b/arch/x86/include/asm/types.h
index 8e8c23f..0829082 100644
--- a/arch/x86/include/asm/types.h
+++ b/arch/x86/include/asm/types.h
@@ -3,4 +3,12 @@
 
 #include <asm-generic/types.h>
 
+#ifdef __KERNEL__
+#if defined(CONFIG_X86_64) && !defined(__ASSEMBLY__) && !defined(_SETUP)
+#define HAVE_INT128
+typedef __int128 s128;
+typedef unsigned __int128 u128;
+#endif
+#endif
+
 #endif /* _ASM_X86_TYPES_H */
diff --git a/include/linux/types.h b/include/linux/types.h
index 9c1bd53..46e67ad 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -127,6 +127,12 @@ typedef		__s64		int64_t;
 #define aligned_be64 __be64 __attribute__((aligned(8)))
 #define aligned_le64 __le64 __attribute__((aligned(8)))
 
+#ifdef HAVE_INT128
+typedef		u128		u_int128_t;
+typedef		u128		uint128_t;
+typedef		s128		int128_t;
+#endif
+
 /**
  * The type used for indexing onto a disc or disc partition.
  *
@@ -199,6 +205,12 @@ typedef __u32 __bitwise __wsum;
 #define __aligned_le64 __le64 __attribute__((aligned(8)))
 
 #ifdef __KERNEL__
+
+#ifdef HAVE_INT128
+typedef u128 __bitwise __le128;
+typedef u128 __bitwise __be128;
+#endif
+
 typedef unsigned __bitwise__ gfp_t;
 typedef unsigned __bitwise__ fmode_t;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
