From: Erik Hensema <erik@hensema.net>
Subject: [Patch 2.4.21-pre4]: promote netfilter MARK values to sit packets
Date: Tue, 18 Feb 2003 13:13:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218121331.GA5848@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This is the patch I sent to the list yesterday, this time including config
options and help. The code should apply to at least 2.4.19 and up, the
Configure.help patch is made against 2.4.21-pre4.

Is this material for lkml and/or Marcello yet?

-- 
Erik Hensema (erik@hensema.net)

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sit-promote-mark-2.4.21-pre4.diff"

diff -ur linux-2.4.21-pre4/Documentation/Configure.help linux-2.4.21-pre4.patched/Documentation/Configure.help
--- linux-2.4.21-pre4/Documentation/Configure.help	Tue Feb 18 12:54:18 2003
+++ linux-2.4.21-pre4.patched/Documentation/Configure.help	Tue Feb 18 12:52:16 2003
@@ -5627,6 +5627,18 @@
 
   It is safe to say N here for now.
 
+IPv6: Promote netfilter MARK value to sit packets
+CONFIG_IPV6_SIT_PROMOTE_MARK
+  If you use IPv6-in-IPv4 tunnels, you can use this option to mark
+  packets using ip6tables, and then match the sit (tunnel) packets
+  using iptables on the IPv4 level, or a tc fw match on the physical
+  outgoing interface.
+
+  You need this if you want to provide QoS on a tunnelled IPv6
+  connection.
+
+  If unsure, say N.
+
 Kernel httpd acceleration
 CONFIG_KHTTPD
   The kernel httpd acceleration daemon (kHTTPd) is a (limited) web
diff -ur linux-2.4.21-pre4/net/ipv6/Config.in linux-2.4.21-pre4.patched/net/ipv6/Config.in
--- linux-2.4.21-pre4/net/ipv6/Config.in	Fri Dec 21 18:42:05 2001
+++ linux-2.4.21-pre4.patched/net/ipv6/Config.in	Tue Feb 18 12:48:50 2003
@@ -7,4 +7,8 @@
 
 if [ "$CONFIG_NETFILTER" != "n" ]; then
    source net/ipv6/netfilter/Config.in
+
+   if [ "$CONFIG_IP6_NF_IPTABLES" != "n" ] ; then
+      bool '  IPv6: Promote netfilter MARK value to sit packets' CONFIG_IPV6_SIT_PROMOTE_MARK
+   fi
 fi
diff -ur linux-2.4.21-pre4/net/ipv6/sit.c linux-2.4.21-pre4.patched/net/ipv6/sit.c
--- linux-2.4.21-pre4/net/ipv6/sit.c	Fri Nov 29 00:53:15 2002
+++ linux-2.4.21-pre4.patched/net/ipv6/sit.c	Tue Feb 18 12:48:23 2003
@@ -571,6 +571,9 @@
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
+#ifdef CONFIG_IPV6_SIT_PROMOTE_MARK
+		new_skb->nfmark = skb->nfmark;
+#endif
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}

--0OAP2g/MAC+5xKAE--
