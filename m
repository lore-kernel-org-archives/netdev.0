From: jamal <hadi@cyberus.ca>
Subject: Re: ing_filter debug messages
Date: 31 Dec 2004 10:10:38 -0500
Message-ID: <1104505838.1048.273.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
	 <1104469666.1049.231.camel@jzny.localdomain>
	 <20041231093827.GG24603@wiggy.net>
	 <1104491510.1047.234.camel@jzny.localdomain>
	 <20041231131553.GA7460@wiggy.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XcQdU1SCo9jgv+Y8JYL7"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041231131553.GA7460@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-XcQdU1SCo9jgv+Y8JYL7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Wichert,
Try also the attached patch with netfilter on and your rules installed.

cheers,
jamal

--=-XcQdU1SCo9jgv+Y8JYL7
Content-Disposition: attachment; filename=indev2-p
Content-Type: text/plain; name=indev2-p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/ipv4/ip_output.c	2004/12/31 14:26:08	1.1
+++ b/net/ipv4/ip_output.c	2004/12/31 14:27:53
@@ -111,6 +111,7 @@
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_loopback_xmit(newskb);
 #endif
+	newskb->input_dev = newskb->dev;
 	netif_rx(newskb);
 	return 0;
 }
--- a/net/ipv6/ip6_output.c	2004-12-24 16:33:51.000000000 -0500
+++ b/net/ipv6/ip6_output.c	2004-12-31 10:29:47.505392096 -0500
@@ -102,7 +102,7 @@
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
 	BUG_TRAP(newskb->dst);
-
+	newskb->input_dev = newskb->dev;
 	netif_rx(newskb);
 	return 0;
 }

--=-XcQdU1SCo9jgv+Y8JYL7--
