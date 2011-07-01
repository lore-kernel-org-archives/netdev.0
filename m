From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/12] lapb: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:09 -0700
Message-ID: <df508186751fe6cd7a0532a1a465cc9c6e260cc7.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3468 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932076Ab1GATns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 15:43:48 -0400
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the case labels the same indent as the switch.

git diff -w shows 80 column reflowing.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/lapb/lapb_iface.c |   30 +-
 net/lapb/lapb_in.c    |  881 ++++++++++++++++++++++++-------------------------
 2 files changed, 444 insertions(+), 467 deletions(-)

diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index d5d8d55..956b7e4 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -300,26 +300,26 @@ int lapb_disconnect_request(struct net_device *dev)
 		goto out;
 
 	switch (lapb->state) {
-		case LAPB_STATE_0:
-			rc = LAPB_NOTCONNECTED;
-			goto out_put;
+	case LAPB_STATE_0:
+		rc = LAPB_NOTCONNECTED;
+		goto out_put;
 
-		case LAPB_STATE_1:
+	case LAPB_STATE_1:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 TX DISC(1)\n", lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S1 TX DISC(1)\n", lapb->dev);
 #endif
 #if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
 #endif
-			lapb_send_control(lapb, LAPB_DISC, LAPB_POLLON, LAPB_COMMAND);
-			lapb->state = LAPB_STATE_0;
-			lapb_start_t1timer(lapb);
-			rc = LAPB_NOTCONNECTED;
-			goto out_put;
-
-		case LAPB_STATE_2:
-			rc = LAPB_OK;
-			goto out_put;
+		lapb_send_control(lapb, LAPB_DISC, LAPB_POLLON, LAPB_COMMAND);
+		lapb->state = LAPB_STATE_0;
+		lapb_start_t1timer(lapb);
+		rc = LAPB_NOTCONNECTED;
+		goto out_put;
+
+	case LAPB_STATE_2:
+		rc = LAPB_OK;
+		goto out_put;
 	}
 
 	lapb_clear_queues(lapb);
diff --git a/net/lapb/lapb_in.c b/net/lapb/lapb_in.c
index 21904a0..2ec1af5 100644
--- a/net/lapb/lapb_in.c
+++ b/net/lapb/lapb_in.c
@@ -44,89 +44,86 @@ static void lapb_state0_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 				struct lapb_frame *frame)
 {
 	switch (frame->type) {
-		case LAPB_SABM:
+	case LAPB_SABM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 RX SABM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S0 RX SABM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			} else {
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		} else {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n", lapb->dev);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state     = LAPB_STATE_3;
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_connect_indication(lapb, LAPB_OK);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state     = LAPB_STATE_3;
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_connect_indication(lapb, LAPB_OK);
+		}
+		break;
 
-		case LAPB_SABME:
+	case LAPB_SABME:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 RX SABME(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S0 RX SABME(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n", lapb->dev);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state     = LAPB_STATE_3;
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_connect_indication(lapb, LAPB_OK);
-			} else {
-#if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state     = LAPB_STATE_3;
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_connect_indication(lapb, LAPB_OK);
+		} else {
+#if LAPB_DEBUG > 1
+			printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		}
+		break;
 
-		case LAPB_DISC:
+	case LAPB_DISC:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 RX DISC(%d)\n",
-			       lapb->dev, frame->pf);
-			printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S0 RX DISC(%d)\n",
+		       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			lapb_send_control(lapb, LAPB_UA, frame->pf,
-					  LAPB_RESPONSE);
-			break;
+		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
+		break;
 
-		default:
-			break;
+	default:
+		break;
 	}
 
 	kfree_skb(skb);
@@ -140,100 +137,97 @@ static void lapb_state1_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 				struct lapb_frame *frame)
 {
 	switch (frame->type) {
-		case LAPB_SABM:
+	case LAPB_SABM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 RX SABM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S1 RX SABM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
-#endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			} else {
-#if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-			}
-			break;
-
-		case LAPB_SABME:
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		} else {
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 RX SABME(%d)\n",
+			printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
 			       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+		}
+		break;
+
+	case LAPB_SABME:
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S1 RX SABME(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-			} else {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			}
-			break;
-
-		case LAPB_DISC:
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+		} else {
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 RX DISC(%d)\n",
-			       lapb->dev, frame->pf);
 			printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
 			       lapb->dev, frame->pf);
 #endif
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
-			break;
+		}
+		break;
 
-		case LAPB_UA:
+	case LAPB_DISC:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 RX UA(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S1 RX DISC(%d)\n",
+		       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (frame->pf) {
-#if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S1 -> S3\n",
-				       lapb->dev);
-#endif
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state     = LAPB_STATE_3;
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_connect_confirmation(lapb, LAPB_OK);
-			}
-			break;
+		lapb_send_control(lapb, LAPB_DM, frame->pf, LAPB_RESPONSE);
+		break;
 
-		case LAPB_DM:
+	case LAPB_UA:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 RX DM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S1 RX UA(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (frame->pf) {
+		if (frame->pf) {
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n",
-				       lapb->dev);
-#endif
-				lapb_clear_queues(lapb);
-				lapb->state = LAPB_STATE_0;
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb_disconnect_indication(lapb, LAPB_REFUSED);
-			}
-			break;
+			printk(KERN_DEBUG "lapb: (%p) S1 -> S3\n", lapb->dev);
+#endif
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state     = LAPB_STATE_3;
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_connect_confirmation(lapb, LAPB_OK);
+		}
+		break;
+
+	case LAPB_DM:
+#if LAPB_DEBUG > 1
+		printk(KERN_DEBUG "lapb: (%p) S1 RX DM(%d)\n",
+		       lapb->dev, frame->pf);
+#endif
+		if (frame->pf) {
+#if LAPB_DEBUG > 0
+			printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
+#endif
+			lapb_clear_queues(lapb);
+			lapb->state = LAPB_STATE_0;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb_disconnect_indication(lapb, LAPB_REFUSED);
+		}
+		break;
 	}
 
 	kfree_skb(skb);
@@ -247,78 +241,73 @@ static void lapb_state2_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 				struct lapb_frame *frame)
 {
 	switch (frame->type) {
-		case LAPB_SABM:
-		case LAPB_SABME:
+	case LAPB_SABM:
+	case LAPB_SABME:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S2 RX {SABM,SABME}(%d)\n",
-			       lapb->dev, frame->pf);
-			printk(KERN_DEBUG "lapb: (%p) S2 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX {SABM,SABME}(%d)\n",
+		       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 TX DM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			lapb_send_control(lapb, LAPB_DM, frame->pf,
-					  LAPB_RESPONSE);
-			break;
+		lapb_send_control(lapb, LAPB_DM, frame->pf, LAPB_RESPONSE);
+		break;
 
-		case LAPB_DISC:
+	case LAPB_DISC:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S2 RX DISC(%d)\n",
-			       lapb->dev, frame->pf);
-			printk(KERN_DEBUG "lapb: (%p) S2 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX DISC(%d)\n",
+		       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 TX UA(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			lapb_send_control(lapb, LAPB_UA, frame->pf,
-					  LAPB_RESPONSE);
-			break;
+		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
+		break;
 
-		case LAPB_UA:
+	case LAPB_UA:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S2 RX UA(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX UA(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (frame->pf) {
+		if (frame->pf) {
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n", lapb->dev);
 #endif
-				lapb->state = LAPB_STATE_0;
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb_disconnect_confirmation(lapb, LAPB_OK);
-			}
-			break;
+			lapb->state = LAPB_STATE_0;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb_disconnect_confirmation(lapb, LAPB_OK);
+		}
+		break;
 
-		case LAPB_DM:
+	case LAPB_DM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (frame->pf) {
+		if (frame->pf) {
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n",
-				       lapb->dev);
-#endif
-				lapb->state = LAPB_STATE_0;
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb_disconnect_confirmation(lapb,
-							     LAPB_NOTCONNECTED);
-			}
-			break;
+			printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n", lapb->dev);
+#endif
+			lapb->state = LAPB_STATE_0;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb_disconnect_confirmation(lapb, LAPB_NOTCONNECTED);
+		}
+		break;
 
-		case LAPB_I:
-		case LAPB_REJ:
-		case LAPB_RNR:
-		case LAPB_RR:
+	case LAPB_I:
+	case LAPB_REJ:
+	case LAPB_RNR:
+	case LAPB_RR:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S2 RX {I,REJ,RNR,RR}"
-			       "(%d)\n", lapb->dev, frame->pf);
-			printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX {I,REJ,RNR,RR}(%d)\n",
+		       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (frame->pf)
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			break;
+		if (frame->pf)
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		break;
 	}
 
 	kfree_skb(skb);
@@ -336,277 +325,267 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 						     LAPB_SMODULUS;
 
 	switch (frame->type) {
-		case LAPB_SABM:
+	case LAPB_SABM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX SABM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX SABM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			} else {
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		} else {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_requeue_frames(lapb);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_requeue_frames(lapb);
+		}
+		break;
 
-		case LAPB_SABME:
+	case LAPB_SABME:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX SABME(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX SABME(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_requeue_frames(lapb);
-			} else {
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_requeue_frames(lapb);
+		} else {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		}
+		break;
 
-		case LAPB_DISC:
+	case LAPB_DISC:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX DISC(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX DISC(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n",
-			       lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n", lapb->dev);
 #endif
-			lapb_clear_queues(lapb);
-			lapb_send_control(lapb, LAPB_UA, frame->pf,
-					  LAPB_RESPONSE);
-			lapb_start_t1timer(lapb);
-			lapb_stop_t2timer(lapb);
-			lapb->state = LAPB_STATE_0;
-			lapb_disconnect_indication(lapb, LAPB_OK);
-			break;
+		lapb_clear_queues(lapb);
+		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
+		lapb_start_t1timer(lapb);
+		lapb_stop_t2timer(lapb);
+		lapb->state = LAPB_STATE_0;
+		lapb_disconnect_indication(lapb, LAPB_OK);
+		break;
 
-		case LAPB_DM:
+	case LAPB_DM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX DM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX DM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n",
-			       lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n", lapb->dev);
 #endif
-			lapb_clear_queues(lapb);
-			lapb->state = LAPB_STATE_0;
-			lapb_start_t1timer(lapb);
-			lapb_stop_t2timer(lapb);
-			lapb_disconnect_indication(lapb, LAPB_NOTCONNECTED);
-			break;
+		lapb_clear_queues(lapb);
+		lapb->state = LAPB_STATE_0;
+		lapb_start_t1timer(lapb);
+		lapb_stop_t2timer(lapb);
+		lapb_disconnect_indication(lapb, LAPB_NOTCONNECTED);
+		break;
 
-		case LAPB_RNR:
+	case LAPB_RNR:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX RNR(%d) R%d\n",
-			       lapb->dev, frame->pf, frame->nr);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX RNR(%d) R%d\n",
+		       lapb->dev, frame->pf, frame->nr);
 #endif
-			lapb->condition |= LAPB_PEER_RX_BUSY_CONDITION;
-			lapb_check_need_response(lapb, frame->cr, frame->pf);
-			if (lapb_validate_nr(lapb, frame->nr)) {
-				lapb_check_iframes_acked(lapb, frame->nr);
-			} else {
-				lapb->frmr_data = *frame;
-				lapb->frmr_type = LAPB_FRMR_Z;
-				lapb_transmit_frmr(lapb);
+		lapb->condition |= LAPB_PEER_RX_BUSY_CONDITION;
+		lapb_check_need_response(lapb, frame->cr, frame->pf);
+		if (lapb_validate_nr(lapb, frame->nr)) {
+			lapb_check_iframes_acked(lapb, frame->nr);
+		} else {
+			lapb->frmr_data = *frame;
+			lapb->frmr_type = LAPB_FRMR_Z;
+			lapb_transmit_frmr(lapb);
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
 #endif
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state   = LAPB_STATE_4;
-				lapb->n2count = 0;
-			}
-			break;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state   = LAPB_STATE_4;
+			lapb->n2count = 0;
+		}
+		break;
 
-		case LAPB_RR:
+	case LAPB_RR:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX RR(%d) R%d\n",
-			       lapb->dev, frame->pf, frame->nr);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX RR(%d) R%d\n",
+		       lapb->dev, frame->pf, frame->nr);
 #endif
-			lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
-			lapb_check_need_response(lapb, frame->cr, frame->pf);
-			if (lapb_validate_nr(lapb, frame->nr)) {
-				lapb_check_iframes_acked(lapb, frame->nr);
-			} else {
-				lapb->frmr_data = *frame;
-				lapb->frmr_type = LAPB_FRMR_Z;
-				lapb_transmit_frmr(lapb);
+		lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
+		lapb_check_need_response(lapb, frame->cr, frame->pf);
+		if (lapb_validate_nr(lapb, frame->nr)) {
+			lapb_check_iframes_acked(lapb, frame->nr);
+		} else {
+			lapb->frmr_data = *frame;
+			lapb->frmr_type = LAPB_FRMR_Z;
+			lapb_transmit_frmr(lapb);
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
 #endif
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state   = LAPB_STATE_4;
-				lapb->n2count = 0;
-			}
-			break;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state   = LAPB_STATE_4;
+			lapb->n2count = 0;
+		}
+		break;
 
-		case LAPB_REJ:
+	case LAPB_REJ:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX REJ(%d) R%d\n",
-			       lapb->dev, frame->pf, frame->nr);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX REJ(%d) R%d\n",
+		       lapb->dev, frame->pf, frame->nr);
 #endif
-			lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
-			lapb_check_need_response(lapb, frame->cr, frame->pf);
-			if (lapb_validate_nr(lapb, frame->nr)) {
-				lapb_frames_acked(lapb, frame->nr);
-				lapb_stop_t1timer(lapb);
-				lapb->n2count = 0;
-				lapb_requeue_frames(lapb);
-			} else {
-				lapb->frmr_data = *frame;
-				lapb->frmr_type = LAPB_FRMR_Z;
-				lapb_transmit_frmr(lapb);
+		lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
+		lapb_check_need_response(lapb, frame->cr, frame->pf);
+		if (lapb_validate_nr(lapb, frame->nr)) {
+			lapb_frames_acked(lapb, frame->nr);
+			lapb_stop_t1timer(lapb);
+			lapb->n2count = 0;
+			lapb_requeue_frames(lapb);
+		} else {
+			lapb->frmr_data = *frame;
+			lapb->frmr_type = LAPB_FRMR_Z;
+			lapb_transmit_frmr(lapb);
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
 #endif
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state   = LAPB_STATE_4;
-				lapb->n2count = 0;
-			}
-			break;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state   = LAPB_STATE_4;
+			lapb->n2count = 0;
+		}
+		break;
 
-		case LAPB_I:
+	case LAPB_I:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX I(%d) S%d R%d\n",
-			       lapb->dev, frame->pf, frame->ns, frame->nr);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX I(%d) S%d R%d\n",
+		       lapb->dev, frame->pf, frame->ns, frame->nr);
 #endif
-			if (!lapb_validate_nr(lapb, frame->nr)) {
-				lapb->frmr_data = *frame;
-				lapb->frmr_type = LAPB_FRMR_Z;
-				lapb_transmit_frmr(lapb);
+		if (!lapb_validate_nr(lapb, frame->nr)) {
+			lapb->frmr_data = *frame;
+			lapb->frmr_type = LAPB_FRMR_Z;
+			lapb_transmit_frmr(lapb);
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
 #endif
-				lapb_start_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state   = LAPB_STATE_4;
-				lapb->n2count = 0;
+			lapb_start_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state   = LAPB_STATE_4;
+			lapb->n2count = 0;
+			break;
+		}
+		if (lapb->condition & LAPB_PEER_RX_BUSY_CONDITION)
+			lapb_frames_acked(lapb, frame->nr);
+		else
+			lapb_check_iframes_acked(lapb, frame->nr);
+
+		if (frame->ns == lapb->vr) {
+			int cn;
+			cn = lapb_data_indication(lapb, skb);
+			queued = 1;
+			/*
+			 * If upper layer has dropped the frame, we
+			 * basically ignore any further protocol
+			 * processing. This will cause the peer
+			 * to re-transmit the frame later like
+			 * a frame lost on the wire.
+			 */
+			if (cn == NET_RX_DROP) {
+				printk(KERN_DEBUG "LAPB: rx congestion\n");
 				break;
 			}
-			if (lapb->condition & LAPB_PEER_RX_BUSY_CONDITION)
-				lapb_frames_acked(lapb, frame->nr);
-			else
-				lapb_check_iframes_acked(lapb, frame->nr);
-
-			if (frame->ns == lapb->vr) {
-				int cn;
-				cn = lapb_data_indication(lapb, skb);
-				queued = 1;
-				/*
-				 * If upper layer has dropped the frame, we
-				 * basically ignore any further protocol
-				 * processing. This will cause the peer
-				 * to re-transmit the frame later like
-				 * a frame lost on the wire.
-				 */
-				if (cn == NET_RX_DROP) {
-					printk(KERN_DEBUG
-					       "LAPB: rx congestion\n");
-					break;
+			lapb->vr = (lapb->vr + 1) % modulus;
+			lapb->condition &= ~LAPB_REJECT_CONDITION;
+			if (frame->pf)
+				lapb_enquiry_response(lapb);
+			else {
+				if (!(lapb->condition &
+				      LAPB_ACK_PENDING_CONDITION)) {
+					lapb->condition |= LAPB_ACK_PENDING_CONDITION;
+					lapb_start_t2timer(lapb);
 				}
-				lapb->vr = (lapb->vr + 1) % modulus;
-				lapb->condition &= ~LAPB_REJECT_CONDITION;
+			}
+		} else {
+			if (lapb->condition & LAPB_REJECT_CONDITION) {
 				if (frame->pf)
 					lapb_enquiry_response(lapb);
-				else {
-					if (!(lapb->condition &
-					      LAPB_ACK_PENDING_CONDITION)) {
-						lapb->condition |= LAPB_ACK_PENDING_CONDITION;
-						lapb_start_t2timer(lapb);
-					}
-				}
 			} else {
-				if (lapb->condition & LAPB_REJECT_CONDITION) {
-					if (frame->pf)
-						lapb_enquiry_response(lapb);
-				} else {
-#if LAPB_DEBUG > 1
-					printk(KERN_DEBUG
-					       "lapb: (%p) S3 TX REJ(%d) R%d\n",
-					       lapb->dev, frame->pf, lapb->vr);
-#endif
-					lapb->condition |= LAPB_REJECT_CONDITION;
-					lapb_send_control(lapb, LAPB_REJ,
-							  frame->pf,
-							  LAPB_RESPONSE);
-					lapb->condition &= ~LAPB_ACK_PENDING_CONDITION;
-				}
+#if LAPB_DEBUG > 1
+				printk(KERN_DEBUG
+				       "lapb: (%p) S3 TX REJ(%d) R%d\n",
+				       lapb->dev, frame->pf, lapb->vr);
+#endif
+				lapb->condition |= LAPB_REJECT_CONDITION;
+				lapb_send_control(lapb, LAPB_REJ, frame->pf,
+						  LAPB_RESPONSE);
+				lapb->condition &= ~LAPB_ACK_PENDING_CONDITION;
 			}
-			break;
+		}
+		break;
 
-		case LAPB_FRMR:
+	case LAPB_FRMR:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX FRMR(%d) %02X "
-			       "%02X %02X %02X %02X\n", lapb->dev, frame->pf,
-			       skb->data[0], skb->data[1], skb->data[2],
-			       skb->data[3], skb->data[4]);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX FRMR(%d) %02X "
+		       "%02X %02X %02X %02X\n", lapb->dev, frame->pf,
+		       skb->data[0], skb->data[1], skb->data[2],
+		       skb->data[3], skb->data[4]);
 #endif
-			lapb_establish_data_link(lapb);
+		lapb_establish_data_link(lapb);
 #if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S1\n",
-			       lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S3 -> S1\n", lapb->dev);
 #endif
-			lapb_requeue_frames(lapb);
-			lapb->state = LAPB_STATE_1;
-			break;
+		lapb_requeue_frames(lapb);
+		lapb->state = LAPB_STATE_1;
+		break;
 
-		case LAPB_ILLEGAL:
+	case LAPB_ILLEGAL:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 RX ILLEGAL(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S3 RX ILLEGAL(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			lapb->frmr_data = *frame;
-			lapb->frmr_type = LAPB_FRMR_W;
-			lapb_transmit_frmr(lapb);
+		lapb->frmr_data = *frame;
+		lapb->frmr_type = LAPB_FRMR_W;
+		lapb_transmit_frmr(lapb);
 #if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
+		printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
 #endif
-			lapb_start_t1timer(lapb);
-			lapb_stop_t2timer(lapb);
-			lapb->state   = LAPB_STATE_4;
-			lapb->n2count = 0;
-			break;
+		lapb_start_t1timer(lapb);
+		lapb_stop_t2timer(lapb);
+		lapb->state   = LAPB_STATE_4;
+		lapb->n2count = 0;
+		break;
 	}
 
 	if (!queued)
@@ -621,75 +600,73 @@ static void lapb_state4_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 				struct lapb_frame *frame)
 {
 	switch (frame->type) {
-		case LAPB_SABM:
+	case LAPB_SABM:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 RX SABM(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S4 RX SABM(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			} else {
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		} else {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n", lapb->dev);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state     = LAPB_STATE_3;
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_connect_indication(lapb, LAPB_OK);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state     = LAPB_STATE_3;
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_connect_indication(lapb, LAPB_OK);
+		}
+		break;
 
-		case LAPB_SABME:
+	case LAPB_SABME:
 #if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 RX SABME(%d)\n",
-			       lapb->dev, frame->pf);
+		printk(KERN_DEBUG "lapb: (%p) S4 RX SABME(%d)\n",
+		       lapb->dev, frame->pf);
 #endif
-			if (lapb->mode & LAPB_EXTENDED) {
+		if (lapb->mode & LAPB_EXTENDED) {
 #if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
-				       lapb->dev, frame->pf);
+			printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
 #if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n",
-				       lapb->dev);
+			printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n", lapb->dev);
 #endif
-				lapb_send_control(lapb, LAPB_UA, frame->pf,
-						  LAPB_RESPONSE);
-				lapb_stop_t1timer(lapb);
-				lapb_stop_t2timer(lapb);
-				lapb->state     = LAPB_STATE_3;
-				lapb->condition = 0x00;
-				lapb->n2count   = 0;
-				lapb->vs        = 0;
-				lapb->vr        = 0;
-				lapb->va        = 0;
-				lapb_connect_indication(lapb, LAPB_OK);
-			} else {
-#if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
-				       lapb->dev, frame->pf);
+			lapb_send_control(lapb, LAPB_UA, frame->pf,
+					  LAPB_RESPONSE);
+			lapb_stop_t1timer(lapb);
+			lapb_stop_t2timer(lapb);
+			lapb->state     = LAPB_STATE_3;
+			lapb->condition = 0x00;
+			lapb->n2count   = 0;
+			lapb->vs        = 0;
+			lapb->vr        = 0;
+			lapb->va        = 0;
+			lapb_connect_indication(lapb, LAPB_OK);
+		} else {
+#if LAPB_DEBUG > 1
+			printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
+			       lapb->dev, frame->pf);
 #endif
-				lapb_send_control(lapb, LAPB_DM, frame->pf,
-						  LAPB_RESPONSE);
-			}
-			break;
+			lapb_send_control(lapb, LAPB_DM, frame->pf,
+					  LAPB_RESPONSE);
+		}
+		break;
 	}
 
 	kfree_skb(skb);
-- 
1.7.6.rc1

