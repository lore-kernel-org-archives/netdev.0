From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 2/4] irda check error on memcpy_fromiovec
Date: Mon, 8 Dec 2003 20:24:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208202414.D30587@build.pdx.osdl.net>
References: <20031208202302.C30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031208202302.C30587@build.pdx.osdl.net>; from chrisw@osdl.org on Mon, Dec 08, 2003 at 08:23:02PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().


===== net/irda/af_irda.c 1.47 vs edited =====
--- 1.47/net/irda/af_irda.c	Tue Nov  4 16:29:43 2003
+++ edited/net/irda/af_irda.c	Fri Dec  5 17:29:04 2003
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
@@ -1549,7 +1553,11 @@
 
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
@@ -1612,7 +1620,11 @@
 
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
