From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/5] xfrm: replace printk with pr_ macro
Date: Fri, 29 Aug 2014 00:09:22 -0700
Message-ID: <20140829071033.739459252@networkplumber.org>
References: <20140829070918.508987897@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54581 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaH2HKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:35 -0400
Received: by mail-pa0-f47.google.com with SMTP id hz1so5890839pad.34
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:35 -0700 (PDT)
Content-Disposition: inline; filename=xfrm-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard macro's for notices.
Silence useless debug message on module load.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/xfrm/xfrm_user.c	2014-08-12 13:07:42.000000000 -0700
+++ b/net/xfrm/xfrm_user.c	2014-08-22 16:51:45.060027772 -0700
@@ -2582,8 +2582,7 @@ static int xfrm_send_state_notify(struct
 	case XFRM_MSG_FLUSHSA:
 		return xfrm_notify_sa_flush(c);
 	default:
-		printk(KERN_NOTICE "xfrm_user: Unknown SA event %d\n",
-		       c->event);
+		pr_notice("xfrm_user: Unknown SA event %d\n", c->event);
 		break;
 	}
 
@@ -2875,8 +2874,7 @@ static int xfrm_send_policy_notify(struc
 	case XFRM_MSG_POLEXPIRE:
 		return xfrm_exp_policy_notify(xp, dir, c);
 	default:
-		printk(KERN_NOTICE "xfrm_user: Unknown Policy event %d\n",
-		       c->event);
+		pr_notice("xfrm_user: Unknown Policy event %d\n", c->event);
 	}
 
 	return 0;
@@ -3031,7 +3029,7 @@ static int __init xfrm_user_init(void)
 {
 	int rv;
 
-	printk(KERN_INFO "Initializing XFRM netlink socket\n");
+	pr_debug("Initializing XFRM netlink socket\n");
 
 	rv = register_pernet_subsys(&xfrm_user_net_ops);
 	if (rv < 0)
