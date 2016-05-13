From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 03/10] bpf: split HAVE_BPF_JIT into cBPF and eBPF variant
Date: Fri, 13 May 2016 19:08:28 +0200
Message-ID: <ee7e973704289fbded9228f75fd84343e3bfdaf3.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41862 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbcEMRJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:02 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the HAVE_BPF_JIT into two for distinguishing cBPF and eBPF JITs.

Current cBPF ones:

  # git grep -n HAVE_CBPF_JIT arch/
  arch/arm/Kconfig:44:    select HAVE_CBPF_JIT
  arch/mips/Kconfig:18:   select HAVE_CBPF_JIT if !CPU_MICROMIPS
  arch/powerpc/Kconfig:129:       select HAVE_CBPF_JIT
  arch/sparc/Kconfig:35:  select HAVE_CBPF_JIT

Current eBPF ones:

  # git grep -n HAVE_EBPF_JIT arch/
  arch/arm64/Kconfig:61:  select HAVE_EBPF_JIT
  arch/s390/Kconfig:126:  select HAVE_EBPF_JIT if PACK_STACK && HAVE_MARCH_Z196_FEATURES
  arch/x86/Kconfig:94:    select HAVE_EBPF_JIT                    if X86_64

Later code also needs this facility to check for eBPF JITs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm/Kconfig     |  2 +-
 arch/arm64/Kconfig   |  2 +-
 arch/mips/Kconfig    |  2 +-
 arch/powerpc/Kconfig |  2 +-
 arch/s390/Kconfig    |  2 +-
 arch/sparc/Kconfig   |  2 +-
 arch/x86/Kconfig     |  2 +-
 net/Kconfig          | 14 +++++++++++---
 8 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index cdfa6c2..2315b0d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -41,7 +41,7 @@ config ARM
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARM_SMCCC if CPU_V7
-	select HAVE_BPF_JIT
+	select HAVE_CBPF_JIT
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CONTEXT_TRACKING
 	select HAVE_C_RECORDMCOUNT
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4f43622..e6761ea 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -58,7 +58,7 @@ config ARM64
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
-	select HAVE_BPF_JIT
+	select HAVE_EBPF_JIT
 	select HAVE_C_RECORDMCOUNT
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CMPXCHG_DOUBLE
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 2018c2b..3ee1ea6 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -15,7 +15,7 @@ config MIPS
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
-	select HAVE_BPF_JIT if !CPU_MICROMIPS
+	select HAVE_CBPF_JIT if !CPU_MICROMIPS
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_FTRACE_MCOUNT_RECORD
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 7cd32c0..2fdb73d 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -126,7 +126,7 @@ config PPC
 	select IRQ_FORCED_THREADING
 	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_SYSCALL_TRACEPOINTS
-	select HAVE_BPF_JIT
+	select HAVE_CBPF_JIT
 	select HAVE_ARCH_JUMP_LABEL
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index bf24ab1..a883981 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -126,7 +126,7 @@ config S390
 	select HAVE_ARCH_SOFT_DIRTY
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	select HAVE_BPF_JIT if PACK_STACK && HAVE_MARCH_Z196_FEATURES
+	select HAVE_EBPF_JIT if PACK_STACK && HAVE_MARCH_Z196_FEATURES
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_DEBUG_KMEMLEAK
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 57ffaf2..d500381 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -32,7 +32,7 @@ config SPARC
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
 	select HAVE_NMI_WATCHDOG if SPARC64
-	select HAVE_BPF_JIT
+	select HAVE_CBPF_JIT
 	select HAVE_DEBUG_BUGVERBOSE
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2dc18605..ae83046 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -91,7 +91,7 @@ config X86
 	select HAVE_ARCH_SOFT_DIRTY		if X86_64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	select HAVE_BPF_JIT			if X86_64
+	select HAVE_EBPF_JIT			if X86_64
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_CMPXCHG_LOCAL
diff --git a/net/Kconfig b/net/Kconfig
index b841c42..f7148f2 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -289,7 +289,7 @@ config BQL
 
 config BPF_JIT
 	bool "enable BPF Just In Time compiler"
-	depends on HAVE_BPF_JIT
+	depends on HAVE_CBPF_JIT || HAVE_EBPF_JIT
 	depends on MODULES
 	---help---
 	  Berkeley Packet Filter filtering capabilities are normally handled
@@ -419,6 +419,14 @@ config MAY_USE_DEVLINK
 
 endif   # if NET
 
-# Used by archs to tell that they support BPF_JIT
-config HAVE_BPF_JIT
+# Used by archs to tell that they support BPF JIT compiler plus which flavour.
+# Only one of the two can be selected for a specific arch since eBPF JIT supersedes
+# the cBPF JIT.
+
+# Classic BPF JIT (cBPF)
+config HAVE_CBPF_JIT
+	bool
+
+# Extended BPF JIT (eBPF)
+config HAVE_EBPF_JIT
 	bool
-- 
1.9.3
