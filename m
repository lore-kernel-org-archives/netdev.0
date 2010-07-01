From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] x86: Drop CONFIG_MCORE2 check around setting of
	NET_IP_ALIGN
Date: Thu, 01 Jul 2010 16:28:27 -0700
Message-ID: <20100701232742.15934.49030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Andi Kleen <ak@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:47892
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753859Ab0GAX26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes the CONFIG_MCORE2 check from around NET_IP_ALIGN.  It is
based on a suggestion from Andi Kleen.  The assumption is that there are
not any x86 cores where unaligned access is really slow, and this change
would allow for a performance improvement to still exist on configurations
that are not necessarily optimized for Core 2.

Cc: Andi Kleen <ak@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 arch/x86/include/asm/system.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
index b4293fc..1db9bd2 100644
--- a/arch/x86/include/asm/system.h
+++ b/arch/x86/include/asm/system.h
@@ -457,7 +457,6 @@ static inline void rdtsc_barrier(void)
 	alternative(ASM_NOP3, "lfence", X86_FEATURE_LFENCE_RDTSC);
 }
 
-#ifdef CONFIG_MCORE2
 /*
  * We handle most unaligned accesses in hardware.  On the other hand
  * unaligned DMA can be quite expensive on some Nehalem processors.
@@ -465,5 +464,4 @@ static inline void rdtsc_barrier(void)
  * Based on this we disable the IP header alignment in network drivers.
  */
 #define NET_IP_ALIGN	0
-#endif
 #endif /* _ASM_X86_SYSTEM_H */

