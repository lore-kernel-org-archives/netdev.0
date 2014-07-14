From: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Bluetooth: cmtp: Remove unnecessary null test
Date: Tue, 15 Jul 2014 02:04:13 +0530
Message-ID: <20140714203412.GA16532@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall-L2FTfq7BK8M@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes the null test on ctrl. ctrl is initialized at the
beginning of the function to &session->ctrl. Since session is
dereferenced prior to the null test, session must be a valid pointer,
and &session->ctrl cannot be null.

The following Coccinelle script is used for detecting the change:

@r@
expression e,f;
identifier g,y;
statement S1,S2;
@@

*e = &f->g
<+...
 f->y
 ...+>
*if (e != NULL || ...)
 S1 else S2

Signed-off-by: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
---
 net/bluetooth/cmtp/capi.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index cd75e4d..1ca8a87 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -362,12 +362,6 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 		CAPIMSG_SETCONTROL(skb->data, contr);
 	}
 
-	if (!ctrl) {
-		BT_ERR("Can't find controller %d for message", session->num);
-		kfree_skb(skb);
-		return;
-	}
-
 	capi_ctr_handle_message(ctrl, appl, skb);
 }
 
-- 
1.9.1
