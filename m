From: Dan Carpenter <error27@gmail.com>
Subject: [patch] af_key: return error if pfkey_xfrm_policy2msg_prep() fails
Date: Wed, 24 Mar 2010 14:47:00 +0300
Message-ID: <20100324114700.GB21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43821 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab0CXLrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 07:47:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code saved the error value but just returned 0 in the end.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 3687078..344145f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2129,10 +2129,9 @@ static int key_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c
 	int err;
 
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
-	if (IS_ERR(out_skb)) {
-		err = PTR_ERR(out_skb);
-		goto out;
-	}
+	if (IS_ERR(out_skb))
+		return PTR_ERR(out_skb);
+
 	err = pfkey_xfrm_policy2msg(out_skb, xp, dir);
 	if (err < 0)
 		return err;
@@ -2148,7 +2147,6 @@ static int key_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c
 	out_hdr->sadb_msg_seq = c->seq;
 	out_hdr->sadb_msg_pid = c->pid;
 	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, NULL, xp_net(xp));
-out:
 	return 0;
 
 }
