From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 module parameter incompatiablity
Date: Tue, 8 Jun 2004 11:04:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608110420.3b93338d@dell_ss3.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "cramerj" <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>,
        "Jeff Garzik" <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

E1000 driver is mixing new style 'module_param' with old style 'MODULE_PARM'
this generates the runtime warning
	e1000: Ignoring new-style parameters in presence of obsolete ones
and prevents using module parameters to set ring size.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2004-06-08 11:01:58 -07:00
+++ b/drivers/net/e1000/e1000_main.c	2004-06-08 11:01:58 -07:00
@@ -202,8 +202,8 @@
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 
-static int debug = 3;
-module_param(debug, int, 0);
+static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+MODULE_PARM(debug, "i");
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /**
