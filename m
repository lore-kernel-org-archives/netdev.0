From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iptables: Fix warning in CONNMARK
Date: Sun, 24 Oct 2004 15:57:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024135721.GO21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@netfilter.org, hno@marasystems.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/net/ipv4/netfilter/ipt_CONNMARK.c	2004-10-24 10:58:49.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/ipv4/netfilter/ipt_CONNMARK.c	2004-10-24 15:35:18.000000000 +0200
@@ -60,7 +60,7 @@
 		break;
 	    case IPT_CONNMARK_RESTORE:
 		nfmark = (*pskb)->nfmark;
-		diff = (ct->mark ^ nfmark & markinfo->mask);
+		diff = ((ct->mark ^ nfmark) & markinfo->mask);
 		if (diff != 0) {
 		    (*pskb)->nfmark = nfmark ^ diff;
 		    (*pskb)->nfcache |= NFC_ALTERED;
