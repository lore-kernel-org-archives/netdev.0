From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/23] netfilter-bridge: use netdev style comments
Date: Fri, 18 Dec 2015 21:26:30 +0100
Message-ID: <1450470409-31427-5-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=n
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ian Morris <ipm@chirality.org.uk>

Changes comments to use netdev style.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_log.c  |  3 +-
 net/bridge/netfilter/ebt_vlan.c | 15 +++++---
 net/bridge/netfilter/ebtables.c | 84 +++++++++++++++++++++------------=
--------
 3 files changed, 56 insertions(+), 46 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_=
log.c
index 0ad639a..f22284d 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -152,7 +152,8 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsign=
ed int hooknum,
 		       ntohs(ah->ar_op));
=20
 		/* If it's for Ethernet and the lengths are OK,
-		 * then log the ARP payload */
+		 * then log the ARP payload
+		 */
 		if (ah->ar_hrd =3D=3D htons(1) &&
 		    ah->ar_hln =3D=3D ETH_ALEN &&
 		    ah->ar_pln =3D=3D sizeof(__be32)) {
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt=
_vlan.c
index 6185688..98c221d 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -66,7 +66,8 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_acti=
on_param *par)
 	 * - Canonical Format Indicator (CFI). The Canonical Format Indicator
 	 * (CFI) is a single bit flag value. Currently ignored.
 	 * - VLAN Identifier (VID). The VID is encoded as
-	 * an unsigned binary number. */
+	 * an unsigned binary number.
+	 */
 	id =3D TCI & VLAN_VID_MASK;
 	prio =3D (TCI >> 13) & 0x7;
=20
@@ -98,7 +99,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_pa=
ram *par)
 	}
=20
 	/* Check for bitmask range
-	 * True if even one bit is out of mask */
+	 * True if even one bit is out of mask
+	 */
 	if (info->bitmask & ~EBT_VLAN_MASK) {
 		pr_debug("bitmask %2X is out of mask (%2X)\n",
 			 info->bitmask, EBT_VLAN_MASK);
@@ -117,7 +119,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_=
param *par)
 	 * 0 - The null VLAN ID.
 	 * 1 - The default Port VID (PVID)
 	 * 0x0FFF - Reserved for implementation use.
-	 * if_vlan.h: VLAN_N_VID 4096. */
+	 * if_vlan.h: VLAN_N_VID 4096.
+	 */
 	if (GET_BITMASK(EBT_VLAN_ID)) {
 		if (!!info->id) { /* if id!=3D0 =3D> check vid range */
 			if (info->id > VLAN_N_VID) {
@@ -128,7 +131,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_=
param *par)
 			/* Note: This is valid VLAN-tagged frame point.
 			 * Any value of user_priority are acceptable,
 			 * but should be ignored according to 802.1Q Std.
-			 * So we just drop the prio flag. */
+			 * So we just drop the prio flag.
+			 */
 			info->bitmask &=3D ~EBT_VLAN_PRIO;
 		}
 		/* Else, id=3D0 (null VLAN ID)  =3D> user_priority range (any?) */
@@ -143,7 +147,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_=
param *par)
 	}
 	/* Check for encapsulated proto range - it is possible to be
 	 * any value for u_short range.
-	 * if_ether.h:  ETH_ZLEN        60   -  Min. octets in frame sans FCS=
 */
+	 * if_ether.h:  ETH_ZLEN        60   -  Min. octets in frame sans FCS
+	 */
 	if (GET_BITMASK(EBT_VLAN_ENCAP)) {
 		if ((unsigned short) ntohs(info->encap) < ETH_ZLEN) {
 			pr_debug("encap frame length %d is less than "
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebt=
ables.c
index 2a0b2f6..62090e2 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -35,8 +35,7 @@
 					 "report to author: "format, ## args)
 /* #define BUGPRINT(format, args...) */
=20
-/*
- * Each cpu has its own set of counters, so there is no need for write=
_lock in
+/* Each cpu has its own set of counters, so there is no need for write=
_lock in
  * the softirq
  * For reading or updating the counters, the user context needs to
  * get a write_lock
@@ -237,7 +236,8 @@ unsigned int ebt_do_table(struct sk_buff *skb,
 		(*(counter_base + i)).bcnt +=3D skb->len;
=20
 		/* these should only watch: not modify, nor tell us
-		   what to do with the packet */
+		 * what to do with the packet
+		 */
 		EBT_WATCHER_ITERATE(point, ebt_do_watcher, skb, &acpar);
=20
 		t =3D (struct ebt_entry_target *)
@@ -451,7 +451,8 @@ static int ebt_verify_pointers(const struct ebt_rep=
lace *repl,
 		if (i !=3D NF_BR_NUMHOOKS || !(e->bitmask & EBT_ENTRY_OR_ENTRIES)) {
 			if (e->bitmask !=3D 0) {
 				/* we make userspace set this right,
-				   so there is no misunderstanding */
+				 * so there is no misunderstanding
+				 */
 				BUGPRINT("EBT_ENTRY_OR_ENTRIES shouldn't be set "
 					 "in distinguisher\n");
 				return -EINVAL;
@@ -487,8 +488,7 @@ static int ebt_verify_pointers(const struct ebt_rep=
lace *repl,
 	return 0;
 }
=20
-/*
- * this one is very careful, as it is the first function
+/* this one is very careful, as it is the first function
  * to parse the userspace data
  */
 static inline int
@@ -504,10 +504,12 @@ ebt_check_entry_size_and_hooks(const struct ebt_e=
ntry *e,
 			break;
 	}
 	/* beginning of a new chain
-	   if i =3D=3D NF_BR_NUMHOOKS it must be a user defined chain */
+	 * if i =3D=3D NF_BR_NUMHOOKS it must be a user defined chain
+	 */
 	if (i !=3D NF_BR_NUMHOOKS || !e->bitmask) {
 		/* this checks if the previous chain has as many entries
-		   as it said it has */
+		 * as it said it has
+		 */
 		if (*n !=3D *cnt) {
 			BUGPRINT("nentries does not equal the nr of entries "
 				 "in the chain\n");
@@ -556,8 +558,7 @@ struct ebt_cl_stack
 	unsigned int hookmask;
 };
=20
-/*
- * we need these positions to check that the jumps to a different part=
 of the
+/* We need these positions to check that the jumps to a different part=
 of the
  * entries is a jump to the beginning of a new chain.
  */
 static inline int
@@ -687,7 +688,8 @@ ebt_check_entry(struct ebt_entry *e, struct net *ne=
t,
 			break;
 	}
 	/* (1 << NF_BR_NUMHOOKS) tells the check functions the rule is on
-	   a base chain */
+	 * a base chain
+	 */
 	if (i < NF_BR_NUMHOOKS)
 		hookmask =3D (1 << hook) | (1 << NF_BR_NUMHOOKS);
 	else {
@@ -758,8 +760,7 @@ cleanup_matches:
 	return ret;
 }
=20
-/*
- * checks for loops and sets the hook mask for udc
+/* checks for loops and sets the hook mask for udc
  * the hook mask for udc tells us from which base chains the udc can b=
e
  * accessed. This mask is a parameter to the check() functions of the =
extensions
  */
@@ -853,7 +854,8 @@ static int translate_table(struct net *net, const c=
har *name,
 		return -EINVAL;
 	}
 	/* make sure chains are ordered after each other in same order
-	   as their corresponding hooks */
+	 * as their corresponding hooks
+	 */
 	for (j =3D i + 1; j < NF_BR_NUMHOOKS; j++) {
 		if (!newinfo->hook_entry[j])
 			continue;
@@ -868,7 +870,8 @@ static int translate_table(struct net *net, const c=
har *name,
 	i =3D 0; /* holds the expected nr. of entries for the chain */
 	j =3D 0; /* holds the up to now counted entries for the chain */
 	k =3D 0; /* holds the total nr. of entries, should equal
-		  newinfo->nentries afterwards */
+		* newinfo->nentries afterwards
+		*/
 	udc_cnt =3D 0; /* will hold the nr. of user defined chains (udc) */
 	ret =3D EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
 	   ebt_check_entry_size_and_hooks, newinfo,
@@ -888,10 +891,12 @@ static int translate_table(struct net *net, const=
 char *name,
 	}
=20
 	/* get the location of the udc, put them in an array
-	   while we're at it, allocate the chainstack */
+	 * while we're at it, allocate the chainstack
+	 */
 	if (udc_cnt) {
 		/* this will get free'd in do_replace()/ebt_register_table()
-		   if an error occurs */
+		 * if an error occurs
+		 */
 		newinfo->chainstack =3D
 			vmalloc(nr_cpu_ids * sizeof(*(newinfo->chainstack)));
 		if (!newinfo->chainstack)
@@ -932,14 +937,15 @@ static int translate_table(struct net *net, const=
 char *name,
 			}
=20
 	/* we now know the following (along with E=3Dmc=C2=B2):
-	   - the nr of entries in each chain is right
-	   - the size of the allocated space is right
-	   - all valid hooks have a corresponding chain
-	   - there are no loops
-	   - wrong data can still be on the level of a single entry
-	   - could be there are jumps to places that are not the
-	     beginning of a chain. This can only occur in chains that
-	     are not accessible from any base chains, so we don't care. */
+	 *  - the nr of entries in each chain is right
+	 *  - the size of the allocated space is right
+	 *  - all valid hooks have a corresponding chain
+	 *  - there are no loops
+	 *  - wrong data can still be on the level of a single entry
+	 *  - could be there are jumps to places that are not the
+	 *    beginning of a chain. This can only occur in chains that
+	 *    are not accessible from any base chains, so we don't care.
+	 */
=20
 	/* used to know what we need to clean up if something goes wrong */
 	i =3D 0;
@@ -986,7 +992,8 @@ static int do_replace_finish(struct net *net, struc=
t ebt_replace *repl,
 	struct ebt_table *t;
=20
 	/* the user wants counters back
-	   the check on the size is done later, when we have the lock */
+	 * the check on the size is done later, when we have the lock
+	 */
 	if (repl->num_counters) {
 		unsigned long size =3D repl->num_counters * sizeof(*counterstmp);
 		counterstmp =3D vmalloc(size);
@@ -1038,9 +1045,10 @@ static int do_replace_finish(struct net *net, st=
ruct ebt_replace *repl,
 	write_unlock_bh(&t->lock);
 	mutex_unlock(&ebt_mutex);
 	/* so, a user can change the chains while having messed up her counte=
r
-	   allocation. Only reason why this is done is because this way the l=
ock
-	   is held only once, while this doesn't bring the kernel into a
-	   dangerous state. */
+	 * allocation. Only reason why this is done is because this way the l=
ock
+	 * is held only once, while this doesn't bring the kernel into a
+	 * dangerous state.
+	 */
 	if (repl->num_counters &&
 	   copy_to_user(repl->counters, counterstmp,
 	   repl->num_counters * sizeof(struct ebt_counter))) {
@@ -1348,7 +1356,8 @@ static inline int ebt_make_matchname(const struct=
 ebt_entry_match *m,
 	char name[EBT_FUNCTION_MAXNAMELEN] =3D {};
=20
 	/* ebtables expects 32 bytes long names but xt_match names are 29 byt=
es
-	   long. Copy 29 bytes and fill remaining bytes with zeroes. */
+	 * long. Copy 29 bytes and fill remaining bytes with zeroes.
+	 */
 	strlcpy(name, m->u.match->name, sizeof(name));
 	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
@@ -1595,8 +1604,7 @@ static int ebt_compat_entry_padsize(void)
 static int ebt_compat_match_offset(const struct xt_match *match,
 				   unsigned int userlen)
 {
-	/*
-	 * ebt_among needs special handling. The kernel .matchsize is
+	/* ebt_among needs special handling. The kernel .matchsize is
 	 * set to -1 at registration time; at runtime an EBT_ALIGN()ed
 	 * value is expected.
 	 * Example: userspace sends 4500, ebt_among.c wants 4504.
@@ -1966,8 +1974,7 @@ static int compat_mtw_from_user(struct compat_ebt=
_entry_mwt *mwt,
 	return off + match_size;
 }
=20
-/*
- * return size of all matches, watchers or target, including necessary
+/* return size of all matches, watchers or target, including necessary
  * alignment and padding.
  */
 static int ebt_size_mwt(struct compat_ebt_entry_mwt *match32,
@@ -2070,8 +2077,7 @@ static int size_entry_mwt(struct ebt_entry *entry=
, const unsigned char *base,
 	if (ret < 0)
 		return ret;
 	buf_start =3D (char *) entry;
-	/*
-	 * 0: matches offset, always follows ebt_entry.
+	/* 0: matches offset, always follows ebt_entry.
 	 * 1: watchers offset, from ebt_entry structure
 	 * 2: target offset, from ebt_entry structure
 	 * 3: next ebt_entry offset, from ebt_entry structure
@@ -2115,8 +2121,7 @@ static int size_entry_mwt(struct ebt_entry *entry=
, const unsigned char *base,
 	return 0;
 }
=20
-/*
- * repl->entries_size is the size of the ebt_entry blob in userspace.
+/* repl->entries_size is the size of the ebt_entry blob in userspace.
  * It might need more memory when copied to a 64 bit kernel in case
  * userspace is 32-bit. So, first task: find out how much memory is ne=
eded.
  *
@@ -2360,8 +2365,7 @@ static int compat_do_ebt_get_ctl(struct sock *sk,=
 int cmd,
 		break;
 	case EBT_SO_GET_ENTRIES:
 	case EBT_SO_GET_INIT_ENTRIES:
-		/*
-		 * try real handler first in case of userland-side padding.
+		/* try real handler first in case of userland-side padding.
 		 * in case we are dealing with an 'ordinary' 32 bit binary
 		 * without 64bit compatibility padding, this will fail right
 		 * after copy_from_user when the *len argument is validated.
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
