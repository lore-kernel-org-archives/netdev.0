From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v2 03/10] snet: introduce security/snet, Makefile and Kconfig changes
Date: Tue,  2 Mar 2010 21:23:07 +0100
Message-ID: <1267561394-13626-4-git-send-email-sam@synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267561394-13626-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this patch creates folder security/snet and adds changes for Kconfig and Makefile

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/Kconfig       |    6 ++++++
 security/Makefile      |    2 ++
 security/snet/Kconfig  |   11 +++++++++++
 security/snet/Makefile |   14 ++++++++++++++
 4 files changed, 33 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/Kconfig
 create mode 100644 security/snet/Makefile

diff --git a/security/Kconfig b/security/Kconfig
index 226b955..eb37e9a 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -140,6 +140,7 @@ config LSM_MMAP_MIN_ADDR
 source security/selinux/Kconfig
 source security/smack/Kconfig
 source security/tomoyo/Kconfig
+source security/snet/Kconfig
 
 source security/integrity/ima/Kconfig
 
@@ -148,6 +149,7 @@ choice
 	default DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX
 	default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
 	default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
+	default DEFAULT_SECURITY_SNET if SECURITY_SNET
 	default DEFAULT_SECURITY_DAC
 
 	help
@@ -163,6 +165,9 @@ choice
 	config DEFAULT_SECURITY_TOMOYO
 		bool "TOMOYO" if SECURITY_TOMOYO=y
 
+	config DEFAULT_SECURITY_SNET
+		bool "snet" if SECURITY_SNET=y
+
 	config DEFAULT_SECURITY_DAC
 		bool "Unix Discretionary Access Controls"
 
@@ -173,6 +178,7 @@ config DEFAULT_SECURITY
 	default "selinux" if DEFAULT_SECURITY_SELINUX
 	default "smack" if DEFAULT_SECURITY_SMACK
 	default "tomoyo" if DEFAULT_SECURITY_TOMOYO
+	default "snet" if DEFAULT_SECURITY_SNET
 	default "" if DEFAULT_SECURITY_DAC
 
 endmenu
diff --git a/security/Makefile b/security/Makefile
index da20a19..9374523 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_KEYS)			+= keys/
 subdir-$(CONFIG_SECURITY_SELINUX)	+= selinux
 subdir-$(CONFIG_SECURITY_SMACK)		+= smack
 subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
+subdir-$(CONFIG_SECURITY_SNET)		+= snet
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -19,6 +20,7 @@ obj-$(CONFIG_SECURITY_SELINUX)		+= selinux/built-in.o
 obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
 obj-$(CONFIG_AUDIT)			+= lsm_audit.o
 obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
+obj-$(CONFIG_SECURITY_SNET)		+= snet/built-in.o
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
 
 # Object integrity file lists
diff --git a/security/snet/Kconfig b/security/snet/Kconfig
new file mode 100644
index 0000000..6dabd7d
--- /dev/null
+++ b/security/snet/Kconfig
@@ -0,0 +1,11 @@
+#
+# snet
+#
+
+config SECURITY_SNET
+	bool "snet - Security for NETwork syscalls"
+	depends on SECURITY_NETWORK
+	default n
+	---help---
+	If this option is enabled, the kernel will include support for reporting
+	networking's syscalls to userspace and wait for a verdict
diff --git a/security/snet/Makefile b/security/snet/Makefile
new file mode 100644
index 0000000..e8f52f1
--- /dev/null
+++ b/security/snet/Makefile
@@ -0,0 +1,14 @@
+#
+# Makefile for building the Security Network Events module.
+#
+obj-$(CONFIG_SECURITY_SNET) :=  snet.o
+
+snet-y := snet_event.o \
+	  snet_netlink_helper.o \
+	  snet_netlink.o \
+	  snet_verdict.o \
+	  snet_ticket_helper.o \
+	  snet_ticket.o \
+	  snet_hooks.o \
+	  snet_core.o \
+	  snet_utils.o
-- 
1.6.3.3
