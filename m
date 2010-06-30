From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline on newer
	core 2/Xeon Arch
Date: Tue, 29 Jun 2010 21:38:00 -0700
Message-ID: <20100630043728.9224.64191.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:54009 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725Ab0F3Ei2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:38:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

x86 architectures can handle unaligned accesses in hardware, and it has
been shown that unaligned DMA accesses can be expensive on Nehalem
architectures.  As such we should overwrite NET_IP_ALIGN to resolve
this issue.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 arch/x86/include/asm/system.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
index b8fe48e..b4293fc 100644
--- a/arch/x86/include/asm/system.h
+++ b/arch/x86/include/asm/system.h
@@ -457,4 +457,13 @@ static inline void rdtsc_barrier(void)
 	alternative(ASM_NOP3, "lfence", X86_FEATURE_LFENCE_RDTSC);
 }
 
+#ifdef CONFIG_MCORE2
+/*
+ * We handle most unaligned accesses in hardware.  On the other hand
+ * unaligned DMA can be quite expensive on some Nehalem processors.
+ *
+ * Based on this we disable the IP header alignment in network drivers.
+ */
+#define NET_IP_ALIGN	0
+#endif
 #endif /* _ASM_X86_SYSTEM_H */

