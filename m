From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: forgotten dev_put for bridge-devices in nf_reinject
Date: Tue, 10 Dec 2002 14:35:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF5EDBE.7000707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000505020000010609080306"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000505020000010609080306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

The attached patch releases the bridge devices grabbed in nf_queue after 
reinjecting the packet.
Seems someone forgot these (or planned to get Rusty killed) ;)

Bye,
Patrick

--------------000505020000010609080306
Content-Type: text/plain;
 name="nfqueue-bridge-devput.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfqueue-bridge-devput.diff"

--- linux-2.5.50/net/core/netfilter.c.orig	2002-12-10 14:16:20.000000000 +0100
+++ linux-2.5.50/net/core/netfilter.c	2002-12-10 14:19:23.000000000 +0100
@@ -574,7 +574,15 @@
 	/* Release those devices we held, or Alexey will kill me. */
 	if (info->indev) dev_put(info->indev);
 	if (info->outdev) dev_put(info->outdev);
-	
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+	if (skb->nf_bridge) {
+		if (skb->nf_bridge->physindev)
+			dev_put(skb->nf_bridge->physindev);
+		if (skb->nf_bridge->physoutdev)
+			dev_put(skb->nf_bridge->physoutdev);
+	}
+#endif
+
 	kfree(info);
 	return;
 }

--------------000505020000010609080306--
