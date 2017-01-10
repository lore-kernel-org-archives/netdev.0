From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] cgroup: move CONFIG_SOCK_CGROUP_DATA to init/Kconfig
Date: Tue, 10 Jan 2017 13:08:06 +0100
Message-ID: <20170110120825.2984218-1-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@kernel.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We now 'select SOCK_CGROUP_DATA' but Kconfig complains that this is
not right when CONFIG_NET is disabled and there is no socket interface:

warning: (CGROUP_BPF) selects SOCK_CGROUP_DATA which has unmet direct dependencies (NET)

I don't know what the correct solution for this is, but simply removing
the dependency on NET from SOCK_CGROUP_DATA by moving it out of the
'if NET' section avoids the warning and does not produce other build
errors.

Fixes: 483c4933ea09 ("cgroup: Fix CGROUP_BPF config")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
There was an earlier patch by Augusto Mecking Caringi, which added
a dependency, see https://lkml.org/lkml/2017/1/2/296.

I could not figure out whether CGROUP_BPF is meaningful without
CONFIG_NET, my version of the patch assumes that it is.
Applying either my version Augusto's to v4.10-rc will kill the
warning.
---
 init/Kconfig | 4 ++++
 net/Kconfig  | 4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 08c5c161f4ad..420d345db391 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1174,6 +1174,10 @@ config CGROUP_DEBUG
 
 	  Say N.
 
+config SOCK_CGROUP_DATA
+	bool
+	default n
+
 endif # CGROUPS
 
 config CHECKPOINT_RESTORE
diff --git a/net/Kconfig b/net/Kconfig
index a1005007224c..a29bb4b41c50 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -258,10 +258,6 @@ config XPS
 config HWBM
        bool
 
-config SOCK_CGROUP_DATA
-	bool
-	default n
-
 config CGROUP_NET_PRIO
 	bool "Network priority cgroup"
 	depends on CGROUPS
-- 
2.9.0
