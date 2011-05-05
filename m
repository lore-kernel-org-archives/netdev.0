From: y@vger.kernel.org
Subject: [RFC v4 11/11] snet: introduce security/snet, Makefile and Kconfig changes
Date: Thu,  5 May 2011 15:59:21 +0200
Message-ID: <34523.6363508322$1304604617@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

this patch creates folder security/snet and adds changes for Kconfig and Makefile

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/Kconfig       |    6 ++++++
 security/Makefile      |    2 ++
 security/snet/Kconfig  |   11 +++++++++++
 security/snet/Makefile |   15 +++++++++++++++
 4 files changed, 34 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/Kconfig
 create mode 100644 security/snet/Makefile

diff --git a/security/Kconfig b/security/Kconfig
index 95accd4..7e393c4 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -184,6 +184,7 @@ source security/selinux/Kconfig
 source security/smack/Kconfig
 source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
+source security/snet/Kconfig
 
 source security/integrity/ima/Kconfig
 
@@ -193,6 +194,7 @@ choice
 	default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
 	default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
 	default DEFAULT_SECURITY_APPARMOR if SECURITY_APPARMOR
+	default DEFAULT_SECURITY_SNET if SECURITY_SNET
 	default DEFAULT_SECURITY_DAC
 
 	help
@@ -211,6 +213,9 @@ choice
 	config DEFAULT_SECURITY_APPARMOR
 		bool "AppArmor" if SECURITY_APPARMOR=y
 
+	config DEFAULT_SECURITY_SNET
+		bool "snet" if SECURITY_SNET=y
+
 	config DEFAULT_SECURITY_DAC
 		bool "Unix Discretionary Access Controls"
 
@@ -222,6 +227,7 @@ config DEFAULT_SECURITY
 	default "smack" if DEFAULT_SECURITY_SMACK
 	default "tomoyo" if DEFAULT_SECURITY_TOMOYO
 	default "apparmor" if DEFAULT_SECURITY_APPARMOR
+	default "snet" if DEFAULT_SECURITY_SNET
 	default "" if DEFAULT_SECURITY_DAC
 
 endmenu
diff --git a/security/Makefile b/security/Makefile
index 8bb0fe9..9e769b2 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -7,6 +7,7 @@ subdir-$(CONFIG_SECURITY_SELINUX)	+= selinux
 subdir-$(CONFIG_SECURITY_SMACK)		+= smack
 subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
+subdir-$(CONFIG_SECURITY_SNET)		+= snet
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -21,6 +22,7 @@ obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
 obj-$(CONFIG_AUDIT)			+= lsm_audit.o
 obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
 obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/built-in.o
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
index 0000000..002c102
--- /dev/null
+++ b/security/snet/Makefile
@@ -0,0 +1,15 @@
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
+	  snet_stats.o \
+	  snet_utils.o
-- 
1.7.4.1
