From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/11] [NET] Reorder struct ipv6_pinfo
Date: Wed, 9 Mar 2005 20:51:42 +0100
Message-ID: <20050309195142.GR31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Converts hop_limit and mcast_hops to signed 16 bits types saving 4 bytes
on 32bit archs and another 4 bytes on 64bit archs.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc4.orig/include/linux/ipv6.h	2005-03-09 19:05:01.000000000 +0100
+++ linux-2.6.11-rc4/include/linux/ipv6.h	2005-03-09 19:06:08.000000000 +0100
@@ -209,8 +209,8 @@
 
 	__u32			flow_label;
 	__u32			frag_size;
-	int			hop_limit;
-	int			mcast_hops;
+	__s16			hop_limit;
+	__s16			mcast_hops;
 	int			mcast_oif;
 
 	/* pktoption flags */
@@ -233,10 +233,11 @@
 				pmtudisc:2,
 				ipv6only:1;
 
+	__u32			dst_cookie;
+
 	struct ipv6_mc_socklist	*ipv6_mc_list;
 	struct ipv6_ac_socklist	*ipv6_ac_list;
 	struct ipv6_fl_socklist *ipv6_fl_list;
-	__u32			dst_cookie;
 
 	struct ipv6_txoptions	*opt;
 	struct sk_buff		*pktoptions;
