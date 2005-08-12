From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 3/8] netpoll: e1000 netpoll tweak
Date: Thu, 11 Aug 2005 21:19:10 -0500
Message-ID: <4.502409567@selenic.com>
References: <3.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <3.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Suggested by Steven Rostedt, matches his patch included in e100.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/drivers/net/e1000/e1000_main.c
===================================================================
--- l.orig/drivers/net/e1000/e1000_main.c	2005-08-06 17:36:32.000000000 -0500
+++ l/drivers/net/e1000/e1000_main.c	2005-08-06 17:55:01.000000000 -0500
@@ -3789,6 +3789,7 @@ e1000_netpoll(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev, NULL);
+	e1000_clean_tx_irq(adapter);
 	enable_irq(adapter->pdev->irq);
 }
 #endif
