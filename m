From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NETFILTER] Fix "undefined reference" error if
 CONFIG_SYSCTL=n
Date: Fri, 10 Sep 2004 15:31:35 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040910.153135.121099678.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hello.

Fix the following error if CONFIG_SYSCTL=n.

| net/built-in.o: In function `tcp_in_window':
| net/built-in.o(.text+0x49571): undefined reference to `ip_ct_log_invalid'
| net/built-in.o: In function `tcp_error':
| net/built-in.o(.text+0x49715): undefined reference to `ip_ct_log_invalid'
| net/built-in.o(.text+0x49756): undefined reference to `ip_ct_log_invalid'
| net/built-in.o(.text+0x497f1): undefined reference to `ip_ct_log_invalid'
| net/built-in.o(.text+0x49823): undefined reference to `ip_ct_log_invalid'
| net/built-in.o(.text+0x49998): more undefined references to `ip_ct_log_invalid' follow
| make: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/netfilter/ip_conntrack_standalone.c 1.40 vs edited =====
--- 1.40/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-09-01 00:27:37 +09:00
+++ edited/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-09-10 15:16:34 +09:00
@@ -48,6 +48,8 @@
 extern atomic_t ip_conntrack_count;
 DECLARE_PER_CPU(struct ip_conntrack_stat, ip_conntrack_stat);
 
+unsigned int ip_ct_log_invalid = 0;
+
 static int kill_proto(const struct ip_conntrack *i, void *data)
 {
 	return (i->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum == 
@@ -522,7 +524,6 @@
 extern unsigned long ip_ct_generic_timeout;
 
 /* Log invalid packets of a given protocol */
-unsigned int ip_ct_log_invalid = 0;
 static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
