From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 2/4] iseries_veth: Set dev->trans_start so watchdog timer works right
Date: Thu, 12 May 2005 17:53:18 +1000
Message-ID: <200505121753.19267.michael@ellerman.id.au>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261250AbVELHxX@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew, Jeff,

The iseries_veth driver doesn't set dev->trans_start in it's TX path. This
will cause the net device watchdog timer to fire earlier than we want it to,
which causes the driver to needlessly reset its connections to other LPARs.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
--

 iseries_veth.c |    2 ++
 1 files changed, 2 insertions(+)

Index: veth-fixes/drivers/net/iseries_veth.c
===================================================================
--- veth-fixes.orig/drivers/net/iseries_veth.c
+++ veth-fixes/drivers/net/iseries_veth.c
@@ -1023,6 +1023,8 @@ static int veth_start_xmit(struct sk_buf
 
 	lpmask = veth_transmit_to_many(skb, lpmask, dev);
 
+	dev->trans_start = jiffies;
+
 	if (! lpmask) {
 		dev_kfree_skb(skb);
 	} else {
