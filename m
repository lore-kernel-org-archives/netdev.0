From: "David S. Miller" <davem@redhat.com>
Subject: Re: Big set of networking updates
Date: Thu, 19 Aug 2004 07:27:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819072730.55df9bd5.davem@redhat.com>
References: <20040818173736.7ad8e58a.davem@redhat.com>
	<20040819121542.GU3921@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040819121542.GU3921@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 14:15:42 +0200
Harald Welte <laforge@netfilter.org> wrote:

> On Wed, Aug 18, 2004 at 05:37:36PM -0700, David S. Miller wrote:
>  
> > 1.1862: [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct(). 
> > 1.1863: [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalone.
> > 1.1864: [NETFILTER]: Need to export ip_ct_log_invalid to modules.
> 
> Forgive my ignorance, but how can I access those changesets without
> having to run proprietary bk software (couldn't find it on http://www.bkbits.net/ web frontend)?

There is a way to get patches on bkbits.net, but not for the
trees hosted specifically on kernel.bkbits.net

Here are those changes cherry picked out for you Harald.
Sorry about that.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 17:07:13-07:00 davem@nuts.davemloft.net 
#   [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct(). 
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/netfilter/ip_conntrack_proto_sctp.c
#   2004/08/18 17:06:37-07:00 davem@nuts.davemloft.net +1 -1
#   [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct().
# 
diff -Nru a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c	2004-08-19 07:15:09 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c	2004-08-19 07:15:09 -07:00
@@ -403,7 +403,7 @@
 		WRITE_UNLOCK(&sctp_lock);
 	}
 
-	ip_ct_refresh(conntrack, *sctp_timeouts[newconntrack]);
+	ip_ct_refresh_acct(conntrack, ctinfo, skb, *sctp_timeouts[newconntrack]);
 
 	if (oldsctpstate == SCTP_CONNTRACK_COOKIE_ECHOED
 		&& CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY
# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 17:09:57-07:00 davem@nuts.davemloft.net 
#   [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalone.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/netfilter/ip_conntrack_core.c
#   2004/08/18 17:09:16-07:00 davem@nuts.davemloft.net +4 -1
#   [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalone.
# 
diff -Nru a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-19 07:15:21 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-19 07:15:21 -07:00
@@ -59,7 +59,10 @@
 
 DECLARE_RWLOCK(ip_conntrack_lock);
 DECLARE_RWLOCK(ip_conntrack_expect_tuple_lock);
-static atomic_t ip_conntrack_count = ATOMIC_INIT(0);
+
+/* ip_conntrack_standalone needs this */
+atomic_t ip_conntrack_count = ATOMIC_INIT(0);
+EXPORT_SYMBOL(ip_conntrack_count);
 
 void (*ip_conntrack_destroyed)(struct ip_conntrack *conntrack) = NULL;
 LIST_HEAD(ip_conntrack_expect_list);
# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 17:11:57-07:00 davem@nuts.davemloft.net 
#   [NETFILTER]: Need to export ip_ct_log_invalid to modules.
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/08/18 17:11:36-07:00 davem@nuts.davemloft.net +1 -0
#   [NETFILTER]: Need to export ip_ct_log_invalid to modules.
# 
diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-19 07:15:34 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-19 07:15:34 -07:00
@@ -905,3 +905,4 @@
 EXPORT_SYMBOL(ip_conntrack_untracked);
 EXPORT_SYMBOL_GPL(ip_conntrack_find_get);
 EXPORT_SYMBOL_GPL(ip_conntrack_put);
+EXPORT_SYMBOL(ip_ct_log_invalid);
