From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH 1/2] kconfig: Introduce IS_DEPENDENCY_SATISFIED()
Date: Mon,  1 Oct 2012 14:21:19 +0200
Message-ID: <1349094080-769-1-git-send-email-anisse@astier.eu>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Michal Marek <mmarek@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Anisse Astier <anisse@astier.eu>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the time, when we use IS_ENABLED() it's to specify a dependency
on a config option that might be enabled. But if this option is enabled
as a module, and we are built-in, then we'll have missing symbols.

This new macro is therefore useful to specify a dependency on another
config. But it also needs to know our own config option in order to
check if the dependency is properly satisfied.

IS_DEPENDENCY_SATISFIED(CONFIG_SELF, CONFIG_FOO) evaluates to 1 if
CONFIG_FOO is set to 'y' or 'm', and set the same as CONFIG_SELF. It
evaluates to 0 otherwise.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 include/linux/kconfig.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/kconfig.h b/include/linux/kconfig.h
index be342b9..8b8ec1f 100644
--- a/include/linux/kconfig.h
+++ b/include/linux/kconfig.h
@@ -43,4 +43,14 @@
  */
 #define IS_MODULE(option) config_enabled(option##_MODULE)
 
+
+/*
+ * IS_DEPENDENCY_SATISFIED(CONFIG_SELF, CONFIG_FOO) evaluates to 1 if
+ * CONFIG_FOO is set to 'y' or 'm', and set the same as CONFIG_SELF.
+ * Useful for specifying build-time config dependencies.
+ */
+#define IS_DEPENDENCY_SATISFIED(self, dependency) \
+	((config_enabled(self) && config_enabled(dependency)) || \
+	 (config_enabled(self##_MODULE) && config_enabled(dependency##_MODULE)))
+
 #endif /* __LINUX_KCONFIG_H */
-- 
1.7.10.3
