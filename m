From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] x86: Align skb w/ start of cache line on
	newer core 2/Xeon Arch
Date: Wed, 02 Jun 2010 15:25:08 -0700
Message-ID: <20100602222506.12962.49240.stgit@localhost.localdomain>
References: <20100602222230.12962.97260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, mingo@redhat.com, tglx@linutronix.de,
	hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100602222230.12962.97260.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

x86 architectures can handle unaligned accesses in hardware, and it has
been shown that unaligned DMA accesses can be expensive on Nehalem
architectures.  As such we should overwrite NET_IP_ALIGN and NET_SKB_PAD
to resolve this issue.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 arch/x86/include/asm/system.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
index b8fe48e..8acb44e 100644
--- a/arch/x86/include/asm/system.h
+++ b/arch/x86/include/asm/system.h
@@ -457,4 +457,16 @@ static inline void rdtsc_barrier(void)
 	alternative(ASM_NOP3, "lfence", X86_FEATURE_LFENCE_RDTSC);
 }
 
+#ifdef CONFIG_MCORE2
+/*
+ * We handle most unaligned accesses in hardware.  On the other hand
+ * unaligned DMA can be quite expensive on some Nehalem processors.
+ *
+ * Based on this we disable the IP header alignment in network drivers.
+ * We also modify NET_SKB_PAD to be a cacheline in size, thus maintaining
+ * cacheline alignment of buffers.
+ */
+#define NET_IP_ALIGN	0
+#define NET_SKB_PAD	L1_CACHE_BYTES
+#endif
 #endif /* _ASM_X86_SYSTEM_H */
