From: Erik Hensema <erik@hensema.net>
Subject: RFC: promote netfilter MARK value from IPv6 packets to sit packets
Date: Mon, 17 Feb 2003 15:57:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030217145727.GA3413@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm new to the list, so be gentle with your flames ;-)

On my outgoing connection to the internet I provide QoS using ratelimiting
and prioritizing packets. However, it's a cablemodem and my provider only
speaks IPv4. Over the connections I run multiple IPv6 tunnels, and I want
to provide QoS on these tunnels too.

QoS however can only be provided on the physical outgoing interface. On
that level, I can only see IPv4 packets and therefore it's impossible to
provide QoS on IPv6 for me.

In order to be able to provide QoS on tunneled IPv6 connections, I've
created a simple patch (definately not ready for inclusion in the kernel,
since it surely needs a configuration option) which promotes the netfilter
MARK value from the IPv6 packets to the sit packets.
Now I can mark packets using ip6tables, and on the ipv4 level I can still
differentiate between the priorities. Problem solved, I'm happy ;-)

Below is the patch, created on Linux 2.4.19:


--- net/ipv6/sit.c.orig	Mon Feb 17 15:30:41 2003
+++ net/ipv6/sit.c	Mon Feb 17 15:29:40 2003
@@ -571,6 +571,9 @@
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
+#ifdef CONFIG_NETFILTER
+		new_skb->nfmark = skb->nfmark;
+#endif
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}

-- 
Erik Hensema (erik@hensema.net)
