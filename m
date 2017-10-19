From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: sched: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 16:28:24 -0500
Message-ID: <20171019212824.GA7885@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.125]:40539 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751346AbdJSV20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:28:26 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id D26494EDA10
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 16:28:25 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/sched/sch_cbq.c      | 1 +
 net/sched/sch_drr.c      | 1 +
 net/sched/sch_fq_codel.c | 1 +
 net/sched/sch_hfsc.c     | 1 +
 net/sched/sch_htb.c      | 1 +
 net/sched/sch_multiq.c   | 1 +
 net/sched/sch_prio.c     | 1 +
 net/sched/sch_qfq.c      | 1 +
 net/sched/sch_sfb.c      | 1 +
 net/sched/sch_sfq.c      | 1 +
 10 files changed, 10 insertions(+)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c3b92d6..6361be7 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -255,6 +255,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_STOLEN:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		case TC_ACT_RECLASSIFY:
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 753dc7a..5bbcef3 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -321,6 +321,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_STOLEN:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 3c40ede..0305d79 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -105,6 +105,7 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_QUEUED:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return 0;
 		}
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index a692184..d04068a 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1144,6 +1144,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_STOLEN:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 57be73c..fa03807 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -244,6 +244,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_STOLEN:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 31e0a28..0122163 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -54,6 +54,7 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	case TC_ACT_QUEUED:
 	case TC_ACT_TRAP:
 		*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		/* fall through */
 	case TC_ACT_SHOT:
 		return NULL;
 	}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 95fad34..2c79559 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -50,6 +50,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_QUEUED:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8694c7b..6962b37 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -709,6 +709,7 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_STOLEN:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 487d375..0678deb 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -268,6 +268,7 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 		case TC_ACT_QUEUED:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return false;
 		}
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 123a53a..6d4b59d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -189,6 +189,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_QUEUED:
 		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			/* fall through */
 		case TC_ACT_SHOT:
 			return 0;
 		}
-- 
2.7.4
