From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 2/4] irda check error on memcpy_fromiovec (resend)
Date: Fri, 16 Jan 2004 14:26:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116142614.T19023@osdlab.pdx.osdl.net>
References: <20040116142502.B19034@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040116142502.B19034@osdlab.pdx.osdl.net>; from chrisw@osdl.org on Fri, Jan 16, 2004 at 02:25:02PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

 net/irda/af_irda.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

===== net/irda/af_irda.c 1.49 vs edited =====
--- 1.49/net/irda/af_irda.c	Fri Jan  9 02:10:53 2004
+++ edited/net/irda/af_irda.c	Fri Jan 16 14:18:02 2004
@@ -1307,7 +1307,11 @@
 	skb_reserve(skb, self->max_header_size + 16);
 
 	asmptr = skb->h.raw = skb_put(skb, len);
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	err = memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
 
 	/*
 	 * Just send the message to TinyTP, and let it deal with possible
@@ -1550,7 +1554,11 @@
 
 	IRDA_DEBUG(4, "%s(), appending user data\n", __FUNCTION__);
 	asmptr = skb->h.raw = skb_put(skb, len);
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	err = memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
 
 	/*
 	 * Just send the message to TinyTP, and let it deal with possible
@@ -1613,7 +1621,11 @@
 
 	IRDA_DEBUG(4, "%s(), appending user data\n", __FUNCTION__);
 	asmptr = skb->h.raw = skb_put(skb, len);
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	err = memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
 
 	err = irlmp_connless_data_request(self->lsap, skb);
 	if (err) {
