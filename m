From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [NETFILTER] Fix "undefined reference" error if
 CONFIG_SYSCTL=n
Date: Fri, 10 Sep 2004 15:38:43 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040910.153843.62140098.yoshfuji@linux-ipv6.org>
References: <20040910.153135.121099678.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20040910.153135.121099678.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <20040910.153135.121099678.yoshfuji@linux-ipv6.org> (at Fri, 10 Sep 2004 15:31:35 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> +unsigned int ip_ct_log_invalid = 0;
> +
>  static int kill_proto(const struct ip_conntrack *i, void *data)
>  {
>  	return (i->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum == 
> @@ -522,7 +524,6 @@
>  extern unsigned long ip_ct_generic_timeout;
>  
>  /* Log invalid packets of a given protocol */
> -unsigned int ip_ct_log_invalid = 0;
>  static int log_invalid_proto_min = 0;
>  static int log_invalid_proto_max = 255;

Or, you may prefer to move related things as well.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/netfilter/ip_conntrack_standalone.c 1.40 vs edited =====
--- 1.40/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-09-01 00:27:37 +09:00
+++ edited/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-09-10 15:32:44 +09:00
@@ -48,6 +48,11 @@
 extern atomic_t ip_conntrack_count;
 DECLARE_PER_CPU(struct ip_conntrack_stat, ip_conntrack_stat);
 
+/* Log invalid packets of a given protocol */
+unsigned int ip_ct_log_invalid = 0;
+static int log_invalid_proto_min = 0;
+static int log_invalid_proto_max = 255;
+
 static int kill_proto(const struct ip_conntrack *i, void *data)
 {
 	return (i->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum == 
@@ -520,11 +525,6 @@
 
 /* From ip_conntrack_proto_icmp.c */
 extern unsigned long ip_ct_generic_timeout;
-
-/* Log invalid packets of a given protocol */
-unsigned int ip_ct_log_invalid = 0;
-static int log_invalid_proto_min = 0;
-static int log_invalid_proto_max = 255;
 
 static struct ctl_table_header *ip_ct_sysctl_header;
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
