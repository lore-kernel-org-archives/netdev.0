From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] net: drop NET dependency from HAVE_BPF_JIT
Date: Mon, 21 May 2012 20:52:02 +0200
Message-ID: <20120521185202.GA6486@merkur.ravnborg.org>
References: <20120521.050300.1434374935904126254.davem@davemloft.net> <CA+55aFzag=LfduvHSmE34nEVYOk=MRhUMzK854+icLwthmz5Ng@mail.gmail.com> <20120521182400.GA6043@merkur.ravnborg.org> <CA+55aFymRE-_1qzCA_n3xYbMseQrZsjJWWX74S3jn5Qyf9Efjw@mail.gmail.com> <CA+55aFy4He9X6wQjATaJukzH1FkyhGqnmC4kb+azKuMmjPGbmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.snhosting.dk ([87.238.248.203]:64055 "EHLO
	smtp.domainteam.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab2EUSwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 14:52:03 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFy4He9X6wQjATaJukzH1FkyhGqnmC4kb+azKuMmjPGbmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 4976b8fc9fd9f876634d6d73e5b808c762e1352a Mon Sep 17 00:00:00 2001
From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 21 May 2012 20:45:37 +0200
Subject: [PATCH] net: drop NET dependency from HAVE_BPF_JIT

There is no point having the NET dependency on the select target,
as it forces all users to depend on NET to tell they support BPF_JIT.
Move the config option to the bottom of the file - this
could be a nice place also for future "selectable" config symbols.

Fix up all users to drop the dependency on NET now that
it is not required to supress warnings for non-NET builds.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
Did a few "make ARCH=xxx allnoconfig" and no warning were triggered.

	Sam

 arch/arm/Kconfig     |    2 +-
 arch/powerpc/Kconfig |    2 +-
 arch/sparc/Kconfig   |    2 +-
 arch/x86/Kconfig     |    2 +-
 net/Kconfig          |    7 ++++---
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 36586db..e19ed3f 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -33,7 +33,7 @@ config ARM
 	select GENERIC_IRQ_SHOW
 	select CPU_PM if (SUSPEND || CPU_IDLE)
 	select GENERIC_PCI_IOMAP
-	select HAVE_BPF_JIT if NET
+	select HAVE_BPF_JIT
 	help
 	  The ARM series is a line of low-power-consumption RISC chip designs
 	  licensed by ARM Ltd and targeted at embedded applications and
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index feab3ba..73ec039 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -141,7 +141,7 @@ config PPC
 	select IRQ_FORCED_THREADING
 	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_SYSCALL_TRACEPOINTS
-	select HAVE_BPF_JIT if (PPC64 && NET)
+	select HAVE_BPF_JIT if PPC64
 	select HAVE_ARCH_JUMP_LABEL
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 6c49ed2..d176c03 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -30,7 +30,7 @@ config SPARC
 	select USE_GENERIC_SMP_HELPERS if SMP
 	select GENERIC_PCI_IOMAP
 	select HAVE_NMI_WATCHDOG if SPARC64
-	select HAVE_BPF_JIT if NET
+	select HAVE_BPF_JIT
 
 config SPARC32
 	def_bool !64BIT
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c9866b0..25f87bc 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -77,7 +77,7 @@ config X86
 	select GENERIC_CLOCKEVENTS_MIN_ADJUST
 	select IRQ_FORCED_THREADING
 	select USE_GENERIC_SMP_HELPERS if SMP
-	select HAVE_BPF_JIT if (X86_64 && NET)
+	select HAVE_BPF_JIT if X86_64
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
diff --git a/net/Kconfig b/net/Kconfig
index 1e47bd0..245831b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -246,9 +246,6 @@ config BQL
 	select DQL
 	default y
 
-config HAVE_BPF_JIT
-	bool
-
 config BPF_JIT
 	bool "enable BPF Just In Time compiler"
 	depends on HAVE_BPF_JIT
@@ -340,3 +337,7 @@ source "net/nfc/Kconfig"
 
 
 endif   # if NET
+
+# Used by archs to tell that they support BPF_JIT
+config HAVE_BPF_JIT
+	bool
-- 
1.6.0.6
