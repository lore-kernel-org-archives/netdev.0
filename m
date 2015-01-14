From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: xt_osf: Use continue to reduce indentation
Date: Wed, 14 Jan 2015 21:34:43 +0100
Message-ID: <1421267689-24894-3-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

Invert logic in test to use continue.

This routine already uses continue, use it a bit more to
minimize > 80 column long lines and unnecessary indentation.

No change in compiled object file.

Other miscellanea:

o Remove trailing whitespace
o Realign arguments to multiline statement

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_osf.c |  169 ++++++++++++++++++++++++------------------------
 1 file changed, 85 insertions(+), 84 deletions(-)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index c529161..0778855 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -225,6 +225,8 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(kf, &xt_osf_fingers[df], finger_entry) {
+		int foptsize, optnum;
+
 		f = &kf->finger;
 
 		if (!(info->flags & XT_OSF_LOG) && strcmp(info->genre, f->genre))
@@ -233,110 +235,109 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 		optp = _optp;
 		fmatch = FMATCH_WRONG;
 
-		if (totlen == f->ss && xt_osf_ttl(skb, info, f->ttl)) {
-			int foptsize, optnum;
+		if (totlen != f->ss || !xt_osf_ttl(skb, info, f->ttl))
+			continue;
 
-			/*
-			 * Should not happen if userspace parser was written correctly.
-			 */
-			if (f->wss.wc >= OSF_WSS_MAX)
-				continue;
+		/*
+		 * Should not happen if userspace parser was written correctly.
+		 */
+		if (f->wss.wc >= OSF_WSS_MAX)
+			continue;
 
-			/* Check options */
+		/* Check options */
 
-			foptsize = 0;
-			for (optnum = 0; optnum < f->opt_num; ++optnum)
-				foptsize += f->opt[optnum].length;
+		foptsize = 0;
+		for (optnum = 0; optnum < f->opt_num; ++optnum)
+			foptsize += f->opt[optnum].length;
 
-			if (foptsize > MAX_IPOPTLEN ||
-				optsize > MAX_IPOPTLEN ||
-				optsize != foptsize)
-				continue;
+		if (foptsize > MAX_IPOPTLEN ||
+		    optsize > MAX_IPOPTLEN ||
+		    optsize != foptsize)
+			continue;
 
-			check_WSS = f->wss.wc;
+		check_WSS = f->wss.wc;
 
-			for (optnum = 0; optnum < f->opt_num; ++optnum) {
-				if (f->opt[optnum].kind == (*optp)) {
-					__u32 len = f->opt[optnum].length;
-					const __u8 *optend = optp + len;
-					int loop_cont = 0;
+		for (optnum = 0; optnum < f->opt_num; ++optnum) {
+			if (f->opt[optnum].kind == (*optp)) {
+				__u32 len = f->opt[optnum].length;
+				const __u8 *optend = optp + len;
+				int loop_cont = 0;
 
-					fmatch = FMATCH_OK;
+				fmatch = FMATCH_OK;
 
-					switch (*optp) {
-					case OSFOPT_MSS:
-						mss = optp[3];
-						mss <<= 8;
-						mss |= optp[2];
+				switch (*optp) {
+				case OSFOPT_MSS:
+					mss = optp[3];
+					mss <<= 8;
+					mss |= optp[2];
 
-						mss = ntohs((__force __be16)mss);
-						break;
-					case OSFOPT_TS:
-						loop_cont = 1;
-						break;
-					}
+					mss = ntohs((__force __be16)mss);
+					break;
+				case OSFOPT_TS:
+					loop_cont = 1;
+					break;
+				}
 
-					optp = optend;
-				} else
-					fmatch = FMATCH_OPT_WRONG;
+				optp = optend;
+			} else
+				fmatch = FMATCH_OPT_WRONG;
 
-				if (fmatch != FMATCH_OK)
-					break;
-			}
+			if (fmatch != FMATCH_OK)
+				break;
+		}
 
-			if (fmatch != FMATCH_OPT_WRONG) {
-				fmatch = FMATCH_WRONG;
+		if (fmatch != FMATCH_OPT_WRONG) {
+			fmatch = FMATCH_WRONG;
 
-				switch (check_WSS) {
-				case OSF_WSS_PLAIN:
-					if (f->wss.val == 0 || window == f->wss.val)
-						fmatch = FMATCH_OK;
-					break;
-				case OSF_WSS_MSS:
-					/*
-					 * Some smart modems decrease mangle MSS to 
-					 * SMART_MSS_2, so we check standard, decreased
-					 * and the one provided in the fingerprint MSS
-					 * values.
-					 */
+			switch (check_WSS) {
+			case OSF_WSS_PLAIN:
+				if (f->wss.val == 0 || window == f->wss.val)
+					fmatch = FMATCH_OK;
+				break;
+			case OSF_WSS_MSS:
+				/*
+				 * Some smart modems decrease mangle MSS to
+				 * SMART_MSS_2, so we check standard, decreased
+				 * and the one provided in the fingerprint MSS
+				 * values.
+				 */
 #define SMART_MSS_1	1460
 #define SMART_MSS_2	1448
-					if (window == f->wss.val * mss ||
-					    window == f->wss.val * SMART_MSS_1 ||
-					    window == f->wss.val * SMART_MSS_2)
-						fmatch = FMATCH_OK;
-					break;
-				case OSF_WSS_MTU:
-					if (window == f->wss.val * (mss + 40) ||
-					    window == f->wss.val * (SMART_MSS_1 + 40) ||
-					    window == f->wss.val * (SMART_MSS_2 + 40))
-						fmatch = FMATCH_OK;
-					break;
-				case OSF_WSS_MODULO:
-					if ((window % f->wss.val) == 0)
-						fmatch = FMATCH_OK;
-					break;
-				}
+				if (window == f->wss.val * mss ||
+				    window == f->wss.val * SMART_MSS_1 ||
+				    window == f->wss.val * SMART_MSS_2)
+					fmatch = FMATCH_OK;
+				break;
+			case OSF_WSS_MTU:
+				if (window == f->wss.val * (mss + 40) ||
+				    window == f->wss.val * (SMART_MSS_1 + 40) ||
+				    window == f->wss.val * (SMART_MSS_2 + 40))
+					fmatch = FMATCH_OK;
+				break;
+			case OSF_WSS_MODULO:
+				if ((window % f->wss.val) == 0)
+					fmatch = FMATCH_OK;
+				break;
 			}
+		}
 
-			if (fmatch != FMATCH_OK)
-				continue;
+		if (fmatch != FMATCH_OK)
+			continue;
 
-			fcount++;
+		fcount++;
 
-			if (info->flags & XT_OSF_LOG)
-				nf_log_packet(net, p->family, p->hooknum, skb,
-					p->in, p->out, NULL,
-					"%s [%s:%s] : %pI4:%d -> %pI4:%d hops=%d\n",
-					f->genre, f->version, f->subtype,
-					&ip->saddr, ntohs(tcp->source),
-					&ip->daddr, ntohs(tcp->dest),
-					f->ttl - ip->ttl);
+		if (info->flags & XT_OSF_LOG)
+			nf_log_packet(net, p->family, p->hooknum, skb,
+				      p->in, p->out, NULL,
+				      "%s [%s:%s] : %pI4:%d -> %pI4:%d hops=%d\n",
+				      f->genre, f->version, f->subtype,
+				      &ip->saddr, ntohs(tcp->source),
+				      &ip->daddr, ntohs(tcp->dest),
+				      f->ttl - ip->ttl);
 
-			if ((info->flags & XT_OSF_LOG) &&
-			    info->loglevel == XT_OSF_LOGLEVEL_FIRST)
-				break;
-		}
+		if ((info->flags & XT_OSF_LOG) &&
+		    info->loglevel == XT_OSF_LOGLEVEL_FIRST)
+			break;
 	}
 	rcu_read_unlock();
 
-- 
1.7.10.4

