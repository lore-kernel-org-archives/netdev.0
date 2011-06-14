From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] net: netfilter: Remove casts of void *
Date: Mon, 13 Jun 2011 19:21:27 -0700
Message-ID: <4d563708387fcb845135b8748ecedf333fa8fc28.1308017857.git.joe@perches.com>
References: <cover.1308017857.git.joe@perches.com>
Cc: Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	ebtables-user@lists.sourceforge.net,
	ebtables-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <cover.1308017857.git.joe@perches.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unnecessary casts of void * clutter the code.

These are the remainder casts after several specific
patches to remove netdev_priv and dev_priv.

Done via coccinelle script:

$ cat cast_void_pointer.cocci
@@
type T;
T *pt;
void *pv;
@@

- pt = (T *)pv;
+ pt = pv;

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/netfilter/ebtables.c    |    2 +-
 net/ipv4/netfilter/arp_tables.c    |   16 ++++++----------
 net/ipv4/netfilter/ip_tables.c     |   13 +++++--------
 net/ipv6/netfilter/ip6_tables.c    |   13 +++++--------
 net/netfilter/ipset/ip_set_core.c  |    2 +-
 net/netfilter/nf_conntrack_proto.c |    2 +-
 6 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 2b5ca1a..a80a44f 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1667,7 +1667,7 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
 	if (*size < sizeof(*ce))
 		return -EINVAL;
 
-	ce = (struct ebt_entry __user *)*dstptr;
+	ce = *dstptr;
 	if (copy_to_user(ce, e, sizeof(*ce)))
 		return -EFAULT;
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index fd7a3f6..ed46cab 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -370,8 +370,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 	 */
 	for (hook = 0; hook < NF_ARP_NUMHOOKS; hook++) {
 		unsigned int pos = newinfo->hook_entry[hook];
-		struct arpt_entry *e
-			= (struct arpt_entry *)(entry0 + pos);
+		struct arpt_entry *e = entry0 + pos;
 
 		if (!(valid_hooks & (1 << hook)))
 			continue;
@@ -422,14 +421,12 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 					if (pos == oldpos)
 						goto next;
 
-					e = (struct arpt_entry *)
-						(entry0 + pos);
+					e = entry0 + pos;
 				} while (oldpos == pos + e->next_offset);
 
 				/* Move along one */
 				size = e->next_offset;
-				e = (struct arpt_entry *)
-					(entry0 + pos + size);
+				e = entry0 + pos + size;
 				e->counters.pcnt = pos;
 				pos += size;
 			} else {
@@ -453,8 +450,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
 				}
-				e = (struct arpt_entry *)
-					(entry0 + newpos);
+				e = entry0 + newpos;
 				e->counters.pcnt = pos;
 				pos = newpos;
 			}
@@ -1286,7 +1282,7 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 
 	ret = 0;
 	origsize = *size;
-	de = (struct arpt_entry *)*dstptr;
+	de = *dstptr;
 	memcpy(de, e, sizeof(struct arpt_entry));
 	memcpy(&de->counters, &e->counters, sizeof(e->counters));
 
@@ -1566,7 +1562,7 @@ static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
 	int ret;
 
 	origsize = *size;
-	ce = (struct compat_arpt_entry __user *)*dstptr;
+	ce = *dstptr;
 	if (copy_to_user(ce, e, sizeof(struct arpt_entry)) != 0 ||
 	    copy_to_user(&ce->counters, &counters[i],
 	    sizeof(counters[i])) != 0)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 7647438..3f142fb 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -505,14 +505,12 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					if (pos == oldpos)
 						goto next;
 
-					e = (struct ipt_entry *)
-						(entry0 + pos);
+					e = entry0 + pos;
 				} while (oldpos == pos + e->next_offset);
 
 				/* Move along one */
 				size = e->next_offset;
-				e = (struct ipt_entry *)
-					(entry0 + pos + size);
+				e = entry0 + pos + size;
 				e->counters.pcnt = pos;
 				pos += size;
 			} else {
@@ -535,8 +533,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
 				}
-				e = (struct ipt_entry *)
-					(entry0 + newpos);
+				e = entry0 + newpos;
 				e->counters.pcnt = pos;
 				pos = newpos;
 			}
@@ -1406,7 +1403,7 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	int ret = 0;
 
 	origsize = *size;
-	ce = (struct compat_ipt_entry __user *)*dstptr;
+	ce = *dstptr;
 	if (copy_to_user(ce, e, sizeof(struct ipt_entry)) != 0 ||
 	    copy_to_user(&ce->counters, &counters[i],
 	    sizeof(counters[i])) != 0)
@@ -1567,7 +1564,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 
 	ret = 0;
 	origsize = *size;
-	de = (struct ipt_entry *)*dstptr;
+	de = *dstptr;
 	memcpy(de, e, sizeof(struct ipt_entry));
 	memcpy(&de->counters, &e->counters, sizeof(e->counters));
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 94874b0..b42eb00 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -527,14 +527,12 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					if (pos == oldpos)
 						goto next;
 
-					e = (struct ip6t_entry *)
-						(entry0 + pos);
+					e = entry0 + pos;
 				} while (oldpos == pos + e->next_offset);
 
 				/* Move along one */
 				size = e->next_offset;
-				e = (struct ip6t_entry *)
-					(entry0 + pos + size);
+				e = entry0 + pos + size;
 				e->counters.pcnt = pos;
 				pos += size;
 			} else {
@@ -557,8 +555,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
 				}
-				e = (struct ip6t_entry *)
-					(entry0 + newpos);
+				e = entry0 + newpos;
 				e->counters.pcnt = pos;
 				pos = newpos;
 			}
@@ -1430,7 +1427,7 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	int ret = 0;
 
 	origsize = *size;
-	ce = (struct compat_ip6t_entry __user *)*dstptr;
+	ce = *dstptr;
 	if (copy_to_user(ce, e, sizeof(struct ip6t_entry)) != 0 ||
 	    copy_to_user(&ce->counters, &counters[i],
 	    sizeof(counters[i])) != 0)
@@ -1590,7 +1587,7 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 
 	ret = 0;
 	origsize = *size;
-	de = (struct ip6t_entry *)*dstptr;
+	de = *dstptr;
 	memcpy(de, e, sizeof(struct ip6t_entry));
 	memcpy(&de->counters, &e->counters, sizeof(e->counters));
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 333b0be..fed7ad0 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1582,7 +1582,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		ret = -EFAULT;
 		goto done;
 	}
-	op = (unsigned *) data;
+	op = data;
 
 	if (*op < IP_SET_OP_VERSION) {
 		/* Check the version at the beginning of operations */
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 5701c8d..9a4143d 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -135,7 +135,7 @@ static int kill_l3proto(struct nf_conn *i, void *data)
 static int kill_l4proto(struct nf_conn *i, void *data)
 {
 	struct nf_conntrack_l4proto *l4proto;
-	l4proto = (struct nf_conntrack_l4proto *)data;
+	l4proto = data;
 	return nf_ct_protonum(i) == l4proto->l4proto &&
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
-- 
1.7.6.rc0

