From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 module parameters use new format
Date: Wed, 9 Jun 2004 13:32:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609133226.7862e2dd@dell_ss3.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
	<20040608110420.3b93338d@dell_ss3.pdx.osdl.net>
	<40C607D9.5090506@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        cramerj
 <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40C607D9.5090506@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e1000 driver was mixing old/new module parameter methods.
Okay, here is the other way to fix it by making the other module
parameters the new format..

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

 
diff -Nru a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
--- a/drivers/net/e1000/e1000_param.c	2004-06-09 13:31:00 -07:00
+++ b/drivers/net/e1000/e1000_param.c	2004-06-09 13:31:00 -07:00
@@ -55,10 +55,11 @@
  * over and over (plus this helps to avoid typo bugs).
  */
 
-#define E1000_PARAM(X, S) \
-static const int __devinitdata X[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
-MODULE_PARM(X, "1-" __MODULE_STRING(E1000_MAX_NIC) "i"); \
-MODULE_PARM_DESC(X, S);
+#define E1000_PARAM(name, desc) \
+static int __devinitdata name[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
+static int num_##name = 0; \
+module_param_array(name, int, num_##name, 0); \
+MODULE_PARM_DESC(name, desc);
 
 /* Transmit Descriptor Count
  *
