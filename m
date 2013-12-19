From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v3=204/8=5D=20drivers=3A=20net=3A=20Include=20new=20header=20file=20in=20sbni=2Ec?=
Date: Thu, 19 Dec 2013 14:22:37 +0530
Message-ID: <036b203aec94b1e688b7bd6ad09c72b3d481bf18.1387382457.git.rashika.kheria@gmail.com>
References: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create a new header file include/net/Space.h which contains
prototype declaration of sbni_probe().

Include the new header file in drivers/net/Space.c and
drivers/net/wan/sbni.c because they use this function.

This eliminates the following warning in wan/sbni.c:
drivers/net/wan/sbni.c:224:12: warning: no previous prototype for =E2=80=
=98sbni_probe=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---

Changes since v2:
Incorrect fix

 drivers/net/Space.c    |   29 +----------------------------
 drivers/net/wan/sbni.c |    1 +
 include/net/Space.h    |   31 +++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 28 deletions(-)
 create mode 100644 include/net/Space.h

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index a7271e0..67977f1 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -32,39 +32,12 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/netlink.h>
+#include <net/Space.h>
=20
 /* A unified ethernet device probe.  This is the easiest way to have e=
very
    ethernet adaptor have the name "eth[0123...]".
    */
=20
-extern struct net_device *hp100_probe(int unit);
-extern struct net_device *ultra_probe(int unit);
-extern struct net_device *wd_probe(int unit);
-extern struct net_device *ne_probe(int unit);
-extern struct net_device *fmv18x_probe(int unit);
-extern struct net_device *i82596_probe(int unit);
-extern struct net_device *ni65_probe(int unit);
-extern struct net_device *sonic_probe(int unit);
-extern struct net_device *smc_init(int unit);
-extern struct net_device *atarilance_probe(int unit);
-extern struct net_device *sun3lance_probe(int unit);
-extern struct net_device *sun3_82586_probe(int unit);
-extern struct net_device *apne_probe(int unit);
-extern struct net_device *cs89x0_probe(int unit);
-extern struct net_device *mvme147lance_probe(int unit);
-extern struct net_device *tc515_probe(int unit);
-extern struct net_device *lance_probe(int unit);
-extern struct net_device *mac8390_probe(int unit);
-extern struct net_device *mac89x0_probe(int unit);
-extern struct net_device *cops_probe(int unit);
-extern struct net_device *ltpc_probe(void);
-
-/* Fibre Channel adapters */
-extern int iph5526_probe(struct net_device *dev);
-
-/* SBNI adapters */
-extern int sbni_probe(int unit);
-
 struct devprobe2 {
 	struct net_device *(*probe)(int unit);
 	int status;	/* non-zero if autoprobe has failed */
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 388ddf6..1b89ecf 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -57,6 +57,7 @@
=20
 #include <net/net_namespace.h>
 #include <net/arp.h>
+#include <net/Space.h>
=20
 #include <asm/io.h>
 #include <asm/types.h>
diff --git a/include/net/Space.h b/include/net/Space.h
new file mode 100644
index 0000000..8a32771
--- /dev/null
+++ b/include/net/Space.h
@@ -0,0 +1,31 @@
+/* A unified ethernet device probe.  This is the easiest way to have e=
very
+ * ethernet adaptor have the name "eth[0123...]".
+ */
+
+struct net_device *hp100_probe(int unit);
+struct net_device *ultra_probe(int unit);
+struct net_device *wd_probe(int unit);
+struct net_device *ne_probe(int unit);
+struct net_device *fmv18x_probe(int unit);
+struct net_device *i82596_probe(int unit);
+struct net_device *ni65_probe(int unit);
+struct net_device *sonic_probe(int unit);
+struct net_device *smc_init(int unit);
+struct net_device *atarilance_probe(int unit);
+struct net_device *sun3lance_probe(int unit);
+struct net_device *sun3_82586_probe(int unit);
+struct net_device *apne_probe(int unit);
+struct net_device *cs89x0_probe(int unit);
+struct net_device *mvme147lance_probe(int unit);
+struct net_device *tc515_probe(int unit);
+struct net_device *lance_probe(int unit);
+struct net_device *mac8390_probe(int unit);
+struct net_device *mac89x0_probe(int unit);
+struct net_device *cops_probe(int unit);
+struct net_device *ltpc_probe(void);
+
+/* Fibre Channel adapters */
+int iph5526_probe(struct net_device *dev);
+
+/* SBNI adapters */
+int sbni_probe(int unit);
--=20
1.7.9.5
