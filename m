From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/7] [IPSEC] Add complete xfrm event notification
Date: Sat, 7 May 2005 17:18:49 +1000
Message-ID: <20050507071849.GB5753@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dc+cDN39EJAMEtIO"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050507071824.GA5753@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--dc+cDN39EJAMEtIO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 07, 2005 at 05:18:24PM +1000, herbert wrote:
> 
> I've made some white space clean-up's.  I'll include an incremental
> patch showing the changes in a reply to this message.

Here goes.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--dc+cDN39EJAMEtIO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-white-space

diff -urN old/include/net/xfrm.h new/include/net/xfrm.h
--- old/include/net/xfrm.h	2005-05-07 15:54:50.000000000 +1000
+++ new/include/net/xfrm.h	2005-05-07 15:38:09.000000000 +1000
@@ -173,13 +173,12 @@
 /* callback structure passed from either netlink or pfkey */
 struct km_event
 {
-	u32	data; 
-	u32	seq; 
-	u32	pid; 
-	u32	event; 
+	u32	data;
+	u32	seq;
+	u32	pid;
+	u32	event;
 };
 
-
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -204,7 +203,6 @@
 extern void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c);
 extern void km_state_notify(struct xfrm_state *x, struct km_event *c);
 
-
 #define XFRM_ACQ_EXPIRES	30
 
 struct xfrm_tmpl;
@@ -309,8 +307,8 @@
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
-
 #define XFRM_KM_TIMEOUT		30
+
 struct xfrm_mgr
 {
 	struct list_head	list;
diff -urN old/net/key/af_key.c new/net/key/af_key.c
--- old/net/key/af_key.c	2005-05-07 15:54:50.000000000 +1000
+++ new/net/key/af_key.c	2005-05-07 15:51:42.000000000 +1000
@@ -1240,7 +1240,7 @@
 	return 0;
 }
 
-static inline int event2poltype (int event)
+static inline int event2poltype(int event)
 {
 	switch (event) {
 	case XFRM_SAP_DELETED:
@@ -1252,14 +1252,14 @@
 	case XFRM_SAP_EXPIRED:
 	//	return SADB_X_SPDEXPIRE;
 	default:
-		printk("pfkey: Unknown policy event %d\n",event);
+		printk("pfkey: Unknown policy event %d\n", event);
 		break;
 	}
 
 	return 0;
 }
 
-static inline int event2keytype (int event)
+static inline int event2keytype(int event)
 {
 	switch (event) {
 	case XFRM_SAP_DELETED:
@@ -1271,7 +1271,7 @@
 	case XFRM_SAP_EXPIRED:
 		return SADB_EXPIRE;
 	default:
-		printk("pfkey: Unknown SA event %d\n",event);
+		printk("pfkey: Unknown SA event %d\n", event);
 		break;
 	}
 
@@ -1298,7 +1298,7 @@
 	skb = pfkey_xfrm_state2msg(x, 0, hsc);
 
 	if (IS_ERR(skb))
-		return  PTR_ERR(skb);
+		return PTR_ERR(skb);
 
 	hdr = (struct sadb_msg *) skb->data;
 	hdr->sadb_msg_version = PF_KEY_V2;
@@ -1948,7 +1948,7 @@
 	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
 }
 
-static int key_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
+static int key_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
@@ -1956,13 +1956,13 @@
 
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb)) {
-		err =  PTR_ERR(out_skb);
+		err = PTR_ERR(out_skb);
 		goto out;
 	}
 	pfkey_xfrm_policy2msg(out_skb, xp, dir);
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version =  PF_KEY_V2;
+	out_hdr->sadb_msg_version = PF_KEY_V2;
 
 	if (c->data && c->event == XFRM_SAP_DELETED)
 		out_hdr->sadb_msg_type = SADB_X_SPDDELETE2;
@@ -2052,18 +2052,16 @@
 	    (err = parse_ipsecrequests(xp, pol)) < 0)
 		goto out;
 
-
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
-
 	if (err) {
 		kfree(xp);
 		return err;
 	}
 
-	if (hdr->sadb_msg_type == SADB_X_SPDUPDATE) 
+	if (hdr->sadb_msg_type == SADB_X_SPDUPDATE)
 		c.event = XFRM_SAP_UPDATED;
-	else 
+	else
 		c.event = XFRM_SAP_ADDED;
 
 	c.seq = hdr->sadb_msg_seq;
@@ -2129,7 +2127,6 @@
 	return err;
 }
 
-
 static int key_pol_get_resp(struct sock *sk, struct xfrm_policy *xp, struct sadb_msg *hdr, int dir)
 {
 	int err;
@@ -2223,6 +2220,7 @@
 {
 	struct sk_buff *skb_out;
 	struct sadb_msg *hdr;
+
 	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb_out)
 		return -ENOBUFS;
@@ -2445,7 +2443,6 @@
 	}
 }
 
-/* XXX: Noisy for now */
 static int key_notify_policy_expire(struct xfrm_policy *xp, struct km_event *c)
 {
 	return 0;
@@ -2493,7 +2490,7 @@
 	case XFRM_SAP_FLUSHED:
 		return key_notify_sa_flush(c);
 	default:
-		printk("pfkey: Unknown SA event %d\n",c->event);
+		printk("pfkey: Unknown SA event %d\n", c->event);
 		break;
 	}
 
@@ -2512,12 +2509,13 @@
 	case XFRM_SAP_FLUSHED:
 		return key_notify_policy_flush(c);
 	default:
-		printk("pfkey: Unknown policy event %d\n",c->event);
+		printk("pfkey: Unknown policy event %d\n", c->event);
 		break;
 	}
 
 	return 0;
 }
+
 static u32 get_acqseq(void)
 {
 	u32 res;
diff -urN old/net/xfrm/xfrm_state.c new/net/xfrm/xfrm_state.c
--- old/net/xfrm/xfrm_state.c	2005-05-07 15:54:50.000000000 +1000
+++ new/net/xfrm/xfrm_state.c	2005-05-07 15:44:40.000000000 +1000
@@ -440,7 +440,6 @@
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
-
 int xfrm_state_add(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
diff -urN old/net/xfrm/xfrm_user.c new/net/xfrm/xfrm_user.c
--- old/net/xfrm/xfrm_user.c	2005-05-07 15:54:50.000000000 +1000
+++ new/net/xfrm/xfrm_user.c	2005-05-07 15:53:09.000000000 +1000
@@ -359,7 +359,6 @@
 	int this_idx;
 };
 
-
 static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -709,7 +708,7 @@
 	if (!xp)
 		return err;
 
-	/* shouldnt excl be based on nlh flags?? 
+	/* shouldnt excl be based on nlh flags??
 	 * Aha! this is anti-netlink really i.e  more pfkey derived
 	 * in netlink excl is a flag and you wouldnt need
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
@@ -720,7 +719,6 @@
 		return err;
 	}
 
-
 	if (!excl)
 		c.event = XFRM_SAP_UPDATED;
 	else
@@ -850,7 +848,6 @@
 	struct km_event c;
 	int delete;
 
-
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
@@ -1124,6 +1121,7 @@
 {
 	struct sk_buff *skb;
 	int hard = c ->data;
+
 	/* fix to do alloc using NLM macros */
 	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
 	if (skb == NULL)
@@ -1150,7 +1148,7 @@
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid,  c->seq,
+	nlh = NLMSG_PUT(skb, c->pid, c->seq,
 			XFRM_MSG_FLUSHSA, sizeof(*p));
 	nlh->nlmsg_flags = 0;
 
@@ -1170,13 +1168,13 @@
 {
 	int l = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
 	if (x->aalg)
-		l+= RTA_SPACE(sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8);
+		l += RTA_SPACE(sizeof(*x->aalg) + (x->aalg->alg_key_len+7)/8);
 	if (x->ealg)
-		l+= RTA_SPACE(sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8);
+		l += RTA_SPACE(sizeof(*x->ealg) + (x->ealg->alg_key_len+7)/8);
 	if (x->calg)
-		l+= RTA_SPACE(sizeof(*(x->calg)));
+		l += RTA_SPACE(sizeof(*x->calg));
 	if (x->encap)
-		l+= RTA_SPACE(sizeof(*x->encap));
+		l += RTA_SPACE(sizeof(*x->encap));
 
 	return l;
 }
@@ -1215,7 +1213,7 @@
 			sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8, x->aalg);
 	if (x->ealg)
 		RTA_PUT(skb, XFRMA_ALG_CRYPT,
-			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);        
+			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);
 	if (x->calg)
 		RTA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 
@@ -1245,7 +1243,7 @@
 	case XFRM_SAP_FLUSHED:
 		return xfrm_notify_sa_flush(c);
 	default:
-		 printk("xfrm_user: Unknown SA event %d\n",c->event);
+		 printk("xfrm_user: Unknown SA event %d\n", c->event);
 		 break;
 	}
 
@@ -1386,7 +1384,6 @@
 	return -1;
 }
 
-
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct sk_buff *skb;
@@ -1406,7 +1403,7 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
-static int xfrm_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
+static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct xfrm_userpolicy_info *p;
 	struct nlmsghdr *nlh;
@@ -1486,7 +1483,7 @@
 	case XFRM_SAP_EXPIRED:
 		return xfrm_exp_policy_notify(xp, dir, c);
 	default:
-		printk("xfrm_user: Unknown Policy event %d\n",c->event);
+		printk("xfrm_user: Unknown Policy event %d\n", c->event);
 	}
 
 	return 0;

--dc+cDN39EJAMEtIO--
