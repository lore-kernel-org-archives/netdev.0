From: Patrick McHardy <kaber@trash.net>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 23:55:59 +0100
Message-ID: <423221FF.8020103@trash.net>
References: <E1D9rZX-0004KE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010502040408080807090105"
Cc: netdev@oss.sgi.com, dtor_core@ameritech.net,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1D9rZX-0004KE-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010502040408080807090105
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>You're right, good catch. IPT_RETURN is interpreted internally by
>>ip_tables, but since the value changed it isn't recognized by ip_tables
>>anymore and returned to nf_iterate() as NF_REPEAT. This patch restores
>>the old value.
> 
> 
> Please fix netfilter_arp while you're at it since it does exactly
> the same thing.

New patch attached, thanks.


--------------010502040408080807090105
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/11 23:54:54+01:00 kaber@coreworks.de 
#   [NETFILTER]: Fix iptables userspace compatibility breakage
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/netfilter_ipv6/ip6_tables.h
#   2005/03/11 23:54:44+01:00 kaber@coreworks.de +1 -1
#   [NETFILTER]: Fix iptables userspace compatibility breakage
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/netfilter_ipv4/ip_tables.h
#   2005/03/11 23:54:44+01:00 kaber@coreworks.de +1 -1
#   [NETFILTER]: Fix iptables userspace compatibility breakage
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/netfilter_arp/arp_tables.h
#   2005/03/11 23:54:44+01:00 kaber@coreworks.de +1 -1
#   [NETFILTER]: Fix iptables userspace compatibility breakage
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
--- a/include/linux/netfilter_arp/arp_tables.h	2005-03-11 23:55:09 +01:00
+++ b/include/linux/netfilter_arp/arp_tables.h	2005-03-11 23:55:09 +01:00
@@ -154,7 +154,7 @@
 #define ARPT_CONTINUE 0xFFFFFFFF
 
 /* For standard target */
-#define ARPT_RETURN (-NF_MAX_VERDICT - 1)
+#define ARPT_RETURN (-NF_REPEAT - 1)
 
 /* The argument to ARPT_SO_GET_INFO */
 struct arpt_getinfo
diff -Nru a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
--- a/include/linux/netfilter_ipv4/ip_tables.h	2005-03-11 23:55:09 +01:00
+++ b/include/linux/netfilter_ipv4/ip_tables.h	2005-03-11 23:55:09 +01:00
@@ -166,7 +166,7 @@
 #define IPT_CONTINUE 0xFFFFFFFF
 
 /* For standard target */
-#define IPT_RETURN (-NF_MAX_VERDICT - 1)
+#define IPT_RETURN (-NF_REPEAT - 1)
 
 /* TCP matching stuff */
 struct ipt_tcp
diff -Nru a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
--- a/include/linux/netfilter_ipv6/ip6_tables.h	2005-03-11 23:55:09 +01:00
+++ b/include/linux/netfilter_ipv6/ip6_tables.h	2005-03-11 23:55:09 +01:00
@@ -166,7 +166,7 @@
 #define IP6T_CONTINUE 0xFFFFFFFF
 
 /* For standard target */
-#define IP6T_RETURN (-NF_MAX_VERDICT - 1)
+#define IP6T_RETURN (-NF_REPEAT - 1)
 
 /* TCP matching stuff */
 struct ip6t_tcp

--------------010502040408080807090105--
