From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] IPv4 Netfilter hook priorities for SELinux
Date: Tue, 6 Jan 2004 15:05:10 -0500 (EST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Xine.LNX.4.44.0401061503180.8482-100000@thoron.boston.redhat.com>
References: <20040106191311.GH934@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <netfilter-devel@lists.netfilter.org>,
   "David S. Miller" <davem@redhat.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040106191311.GH934@obroa-skai.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 6 Jan 2004, Harald Welte wrote:

> On Tue, Jan 06, 2004 at 11:01:03AM -0500, James Morris wrote:
>  
> > Does anyone have any objections to the patch below (which I'd propose for 
> > 2.6.2), or other comments?
> 
> Thanks James, I am perfectly fine with your patch.  Feel free to put
> them into netfilter_arp.h and netfilter_ipv6.h, too.

Ok, here is the patch with support for IPv4 and IPv6.  I've not added 
anything for ARP yet as SELinux does not have any ARP controls at this 
stage (and probably won't in the near future).

Please apply.


- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv4.h linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv4.h
--- linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv4.h	2003-09-27 20:50:51.000000000 -0400
+++ linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv4.h	2004-01-06 10:14:59.000000000 -0500
@@ -51,6 +51,7 @@
 
 enum nf_ip_hook_priorities {
 	NF_IP_PRI_FIRST = INT_MIN,
+	NF_IP_PRI_SELINUX_FIRST = -225,
 	NF_IP_PRI_CONNTRACK = -200,
 	NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD = -175,
 	NF_IP_PRI_MANGLE = -150,
@@ -58,6 +59,7 @@
 	NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT = -50,
 	NF_IP_PRI_FILTER = 0,
 	NF_IP_PRI_NAT_SRC = 100,
+	NF_IP_PRI_SELINUX_LAST = 225,
 	NF_IP_PRI_LAST = INT_MAX,
 };
 
diff -urN -X dontdiff linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv6.h linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv6.h
--- linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv6.h	2003-09-27 20:50:51.000000000 -0400
+++ linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv6.h	2004-01-06 14:41:30.000000000 -0500
@@ -56,11 +56,13 @@
 
 enum nf_ip6_hook_priorities {
 	NF_IP6_PRI_FIRST = INT_MIN,
+	NF_IP6_PRI_SELINUX_FIRST = -225,
 	NF_IP6_PRI_CONNTRACK = -200,
 	NF_IP6_PRI_MANGLE = -150,
 	NF_IP6_PRI_NAT_DST = -100,
 	NF_IP6_PRI_FILTER = 0,
 	NF_IP6_PRI_NAT_SRC = 100,
+	NF_IP6_PRI_SELINUX_LAST = 225,
 	NF_IP6_PRI_LAST = INT_MAX,
 };
 
