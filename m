From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the final tree
Date: Thu, 21 Jul 2011 23:26:51 -0700 (PDT)
Message-ID: <20110721.232651.1449248174820939714.davem@davemloft.net>
References: <20110722162433.a280b3b71cff9c08fe18956f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, matt@ozlabs.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110722162433.a280b3b71cff9c08fe18956f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 22 Jul 2011 16:24:33 +1000

> warning: (PPC) selects HAVE_BPF_JIT which has unmet direct dependencies (NET)
> 
> Introduced by commit 0ca87f05ba8b ("net: filter: BPF 'JIT' compiler for
> PPC64").
> 
> I suspect that the fix is to move the
> 
> config HAVE_BPF_JIT
>         bool
> 
> lines to outside the "if NET" in net/Kconfig.

I'm going to fix this the way it's dealt with in the x86_64 case
for now, thanks for the report:

--------------------
net: Fix ppc64 BPF JIT dependencies.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/powerpc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 39860fc..cdf7a0a 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -134,7 +134,7 @@ config PPC
 	select GENERIC_IRQ_SHOW_LEVEL
 	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_SYSCALL_TRACEPOINTS
-	select HAVE_BPF_JIT if PPC64
+	select HAVE_BPF_JIT if (PPC64 && NET)
 
 config EARLY_PRINTK
 	bool
-- 
1.7.6
