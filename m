From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V2 resend] net: dsa/slave: Fix compilation warnings
Date: Sat, 24 Nov 2012 11:23:54 +0530
Message-ID: <ecc711bf44722707f57188ee953bbde2f1e20c8c.1353736229.git.viresh.kumar@linaro.org>
Cc: netdev@vger.kernel.org, linaro-dev@lists.linaro.org,
	linux-kernel@vger.kernel.org, patches@linaro.org,
	Viresh Kumar <viresh.kumar@linaro.org>
To: bhutchings@solarflare.com, davem@davemloft.net,
	akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and
CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation warnings:

net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used [-Wunused-function]
net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used [-Wunused-function]
net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not used [-Wunused-function]
net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined but not used [-Wunused-function]
net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but not used [-Wunused-function]
net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined but not used [-Wunused-function]
net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not used [-Wunused-function]

Earlier approach to fix this was discussed here:

lkml.org/lkml/2012/10/29/549

This is another approach to fix it. This is done by some changes in config
options, which make more sense than the earlier approach. As, atleast one
tagging option must always be selected for using net/dsa/ infrastructure, this
patch selects NET_DSA from tagging configs instead of having it as an selectable
config.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
I am resending it as the earlier thread is lost somewhere in Maintainers mailbox
:)

 drivers/net/dsa/Kconfig |  1 -
 net/dsa/Kconfig         | 16 +++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index dd151d5..96eae22 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -1,5 +1,4 @@
 menu "Distributed Switch Architecture drivers"
-	depends on NET_DSA
 
 config NET_DSA_MV88E6XXX
 	tristate
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 9c09f6e..3588e54 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,5 +1,5 @@
 config NET_DSA
-	tristate "Distributed Switch Architecture support"
+	tristate
 	default n
 	depends on NETDEVICES && !S390
 	select PHYLIB
@@ -8,19 +8,21 @@ config NET_DSA
 	  the Distributed Switch Architecture.
 
 
-if NET_DSA
+menu "Distributed Switch Architecture support"
 
 # tagging formats
 config NET_DSA_TAG_DSA
-	bool
+	bool "Original DSA packet tagging format"
+	select NET_DSA
 	default n
 
 config NET_DSA_TAG_EDSA
-	bool
+	bool "Ethertype DSA packet tagging format"
+	select NET_DSA
 	default n
 
 config NET_DSA_TAG_TRAILER
-	bool
+	bool "Trailer DSA packet tagging format"
+	select NET_DSA
 	default n
-
-endif
+endmenu
-- 
1.7.12.rc2.18.g61b472e
