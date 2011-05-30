From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH] uts: Make default hostname configurable, rather than always
 using "(none)"
Date: Mon, 30 May 2011 15:38:47 -0700
Message-ID: <20110530223847.GA29245@leaf>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kel Modderman <kel@otaku42.de>,
	pkg-sysvinit-devel@lists.alioth.debian.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "hostname" tool falls back to setting the hostname to "localhost" if
/etc/hostname does not exist.  Distribution init scripts have the same
fallback.  However, if userspace never calls sethostname, such as when
booting with init=/bin/sh, or otherwise booting a minimal system without
the usual init scripts, the default hostname of "(none)" remains,
unhelpfully appearing in various places such as prompts
("root@(none):~#") and logs.  Furthermore, "(none)" doesn't typically
resolve to anything useful.

Make the default hostname configurable.  This removes the need for the
standard fallback, provides a useful default for systems that never call
sethostname, and makes minimal systems that much more useful with less
configuration.  Distributions could choose to use "localhost" here to
avoid the fallback, while embedded systems may wish to use a specific
target hostname.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---

Revised from my original patch that just changed the default to
"localhost"; this patch makes the default configurable, and leaves the
default default as "(none)".

 include/linux/uts.h |    2 +-
 init/Kconfig        |    9 +++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/uts.h b/include/linux/uts.h
index 73eb1ed..6ddbd86 100644
--- a/include/linux/uts.h
+++ b/include/linux/uts.h
@@ -9,7 +9,7 @@
 #endif
 
 #ifndef UTS_NODENAME
-#define UTS_NODENAME "(none)"	/* set by sethostname() */
+#define UTS_NODENAME CONFIG_DEFAULT_HOSTNAME /* set by sethostname() */
 #endif
 
 #ifndef UTS_DOMAINNAME
diff --git a/init/Kconfig b/init/Kconfig
index ebafac4..e0a22e4 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -204,6 +204,15 @@ config KERNEL_LZO
 
 endchoice
 
+config DEFAULT_HOSTNAME
+	string "Default hostname"
+	default "(none)"
+	help
+	  This option determines the default system hostname before userspace
+	  calls sethostname(2). The kernel traditionally uses "(none)" here,
+	  but you may wish to use a different default here to make a minimal
+	  system more usable with less configuration.
+
 config SWAP
 	bool "Support for paging of anonymous memory (swap)"
 	depends on MMU && BLOCK
-- 
1.7.5.3
