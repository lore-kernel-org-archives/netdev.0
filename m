From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4 of 5][ATM]: get accounting right when we remove skb
Date: Wed, 26 Jan 2005 11:57:53 -0500
Message-ID: <200501261657.j0QGvqll018872@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/24 13:25:27-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: get accounting right when we remove skb
#   
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/svc.c
#   2005/01/24 13:25:10-05:00 chas@relax.cmf.nrl.navy.mil +1 -0
#   [ATM]: get accounting right when we remove skb
#   
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2005-01-25 09:36:57 -05:00
+++ b/net/atm/svc.c	2005-01-25 09:36:57 -05:00
@@ -67,6 +67,7 @@
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
 	while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
+		atm_return(vcc, skb->truesize);
 		DPRINTK("LISTEN REL\n");
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
