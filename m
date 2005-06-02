From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net: fix sysctl_
Date: Thu, 2 Jun 2005 11:19:09 -0700
Message-ID: <20050602111909.63ef419a@dxpl.pdx.osdl.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Changing the sysctl net.core.dev_weight has no effect because the weight
of the backlog devices is set during initialization and never changed.

This patch propagates any changes to the global value affected by sysctl
to the per-cpu devices. It is done every time the packet handler
function is run.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


Index: skge-0.8/net/core/dev.c
===================================================================
--- skge-0.8.orig/net/core/dev.c
+++ skge-0.8/net/core/dev.c
@@ -1732,6 +1732,7 @@ static int process_backlog(struct net_de
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
 
+	backlog_dev->weight = weight_p;
 	for (;;) {
 		struct sk_buff *skb;
 		struct net_device *dev;
