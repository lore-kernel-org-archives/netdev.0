From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] IPV6 debug printk error and missing release in error path
Date: Fri, 19 Dec 2003 13:24:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219132431.37980ccb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        "David S.
 Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A couple of small fixes for IPV6 network discovery:
  * A NPRINTK2 in ndisc_parse_options would not compile if ND_DEBUG level was up to 3
  * missing dst_release in ndisc_send_rs error path if skb_alloc fails.

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	Fri Dec 19 13:21:11 2003
+++ b/net/ipv6/ndisc.c	Fri Dec 19 13:21:11 2003
@@ -207,9 +207,8 @@
 		case ND_OPT_MTU:
 		case ND_OPT_REDIRECT_HDR:
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
-				ND_PRINTK2((KERN_WARNING
-					    "ndisc_parse_options(): duplicated ND6 option found: type=%d\n",
-					    nd_opt->nd_opt_type));
+				ND_PRINTK2("ndisc_parse_options(): duplicated ND6 option found: type=%d\n",
+					    nd_opt->nd_opt_type);
 			} else {
 				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
 			}
@@ -619,6 +618,7 @@
 				  1, &err);
 	if (skb == NULL) {
 		ND_PRINTK1("send_ns: alloc skb failed\n");
+		dst_release(dst);
 		return;
 	}
 
