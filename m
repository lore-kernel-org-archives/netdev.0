From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] arch: add ARCH_HAS_SET_MEMORY config
Date: Tue, 21 Feb 2017 16:09:33 +0100
Message-ID: <54542285e1e8accb513db0fee0f5f830aea45d80.1487688093.git.daniel@iogearbox.net>
References: <cover.1487688093.git.daniel@iogearbox.net>
Cc: ast@kernel.org, labbott@redhat.com, eric.dumazet@gmail.com,
        willemb@google.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56268 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdBUPKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 10:10:18 -0500
In-Reply-To: <cover.1487688093.git.daniel@iogearbox.net>
In-Reply-To: <cover.1487688093.git.daniel@iogearbox.net>
References: <cover.1487688093.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there's no good way to test for the presence of
set_memory_ro/rw/x/nx() helpers implemented by archs such as
x86, arm, arm64 and s390.

There's DEBUG_SET_MODULE_RONX and DEBUG_RODATA, however both
don't really reflect that: set_memory_*() are also available
even when DEBUG_SET_MODULE_RONX is turned off, and DEBUG_RODATA
is set by parisc, but doesn't implement above functions. Thus,
add ARCH_HAS_SET_MEMORY that is selected by mentioned archs,
where generic code can test against this.

This also allows later on to move DEBUG_SET_MODULE_RONX out of
the arch specific Kconfig to define it only once depending on
ARCH_HAS_SET_MEMORY.

Suggested-by: Laura Abbott <labbott@redhat.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/Kconfig       | 4 ++++
 arch/arm/Kconfig   | 1 +
 arch/arm64/Kconfig | 1 +
 arch/s390/Kconfig  | 1 +
 arch/x86/Kconfig   | 1 +
 5 files changed, 8 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index bd04eac..e8ada79 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -222,6 +222,10 @@ config GENERIC_SMP_IDLE_THREAD
 config GENERIC_IDLE_POLL_SETUP
        bool
 
+# Select if arch has all set_memory_ro/rw/x/nx() functions in asm/cacheflush.h
+config ARCH_HAS_SET_MEMORY
+	bool
+
 # Select if arch init_task initializer is different to init/init_task.c
 config ARCH_INIT_TASK
        bool
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 186c4c2..edae056 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -4,6 +4,7 @@ config ARM
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
+	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 1117421..1853405 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -12,6 +12,7 @@ config ARM64
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_USE_CMPXCHG_LOCKREF
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index c6722112..094deb1 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -72,6 +72,7 @@ config S390
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e487493..434dd2a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -53,6 +53,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MMIO_FLUSH
 	select ARCH_HAS_PMEM_API		if X86_64
+	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
-- 
1.9.3
