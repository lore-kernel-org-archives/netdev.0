From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] xfrm: add severity to printk
Date: Wed, 12 May 2010 09:37:06 -0700
Message-ID: <20100512163719.498741963@vyatta.com>
References: <20100512163704.780058547@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36019 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756528Ab0ELQlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 12:41:16 -0400
Content-Disposition: inline; filename=xfrm-message.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serious oh sh*t messages converted to WARN().
Add KERN_NOTICE severity to the unknown policy type messages.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/xfrm/xfrm_user.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

--- a/net/xfrm/xfrm_user.c	2010-05-11 21:08:58.618677963 -0700
+++ b/net/xfrm/xfrm_user.c	2010-05-11 21:12:36.339276557 -0700
@@ -1783,7 +1783,7 @@ static int xfrm_add_pol_expire(struct sk
 
 	} else {
 		// reset the timers here?
-		printk("Dont know what to do with soft policy expire\n");
+		WARN(1, "Dont know what to do with soft policy expire\n");
 	}
 	km_policy_expired(xp, p->dir, up->hard, current->pid);
 
@@ -1883,7 +1883,7 @@ static int xfrm_add_acquire(struct sk_bu
 	return 0;
 
 bad_policy:
-	printk("BAD policy passed\n");
+	WARN(1, "BAD policy passed\n");
 free_state:
 	kfree(x);
 nomem:
@@ -2385,8 +2385,9 @@ static int xfrm_send_state_notify(struct
 	case XFRM_MSG_FLUSHSA:
 		return xfrm_notify_sa_flush(c);
 	default:
-		 printk("xfrm_user: Unknown SA event %d\n", c->event);
-		 break;
+		printk(KERN_NOTICE "xfrm_user: Unknown SA event %d\n",
+		       c->event);
+		break;
 	}
 
 	return 0;
@@ -2676,7 +2677,8 @@ static int xfrm_send_policy_notify(struc
 	case XFRM_MSG_POLEXPIRE:
 		return xfrm_exp_policy_notify(xp, dir, c);
 	default:
-		printk("xfrm_user: Unknown Policy event %d\n", c->event);
+		printk(KERN_NOTICE "xfrm_user: Unknown Policy event %d\n",
+		       c->event);
 	}
 
 	return 0;


