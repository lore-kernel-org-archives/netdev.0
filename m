From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] ipconfig: fix trivial build error
Date: Tue, 25 Sep 2012 11:09:58 +0300
Message-ID: <1348560598-21233-1-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1348255713.12456.43.camel@mars>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christoph Fritz <chf.fritz@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1348255713.12456.43.camel@mars>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit 5e953778a2aab04929a5e7b69f53dc26e39b079e ("ipconfig: add nameserver
IPs to kernel-parameter ip=") introduces ic_nameservers_predef() that defined
only for BOOTP. However it is used by ip_auto_config_setup() as well. This
patch moves it outside of #ifdef BOOTP.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Christoph Fritz <chf.fritz@googlemail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipconfig.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 1c0e7e0..798358b 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -583,6 +583,17 @@ static void __init ic_rarp_send_if(struct ic_device *d)
 #endif
 
 /*
+ *  Predefine Nameservers
+ */
+static inline void __init ic_nameservers_predef(void)
+{
+	int i;
+
+	for (i = 0; i < CONF_NAMESERVERS_MAX; i++)
+		ic_nameservers[i] = NONE;
+}
+
+/*
  *	DHCP/BOOTP support.
  */
 
@@ -743,17 +754,6 @@ static void __init ic_bootp_init_ext(u8 *e)
 
 
 /*
- *  Predefine Nameservers
- */
-static inline void __init ic_nameservers_predef(void)
-{
-	int i;
-
-	for (i = 0; i < CONF_NAMESERVERS_MAX; i++)
-		ic_nameservers[i] = NONE;
-}
-
-/*
  *  Initialize the DHCP/BOOTP mechanism.
  */
 static inline void __init ic_bootp_init(void)
-- 
1.7.10.4
