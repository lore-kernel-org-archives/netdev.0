From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 1/4] ax25 check error on memcpy_fromiovec
Date: Mon, 8 Dec 2003 20:23:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208202302.C30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

===== net/ax25/af_ax25.c 1.33 vs edited =====
--- 1.33/net/ax25/af_ax25.c	Tue Oct  7 06:27:14 2003
+++ edited/net/ax25/af_ax25.c	Fri Dec  5 16:43:44 2003
@@ -1534,7 +1534,12 @@
 	SOCK_DEBUG(sk, "AX.25: Appending user data\n");
 
 	/* User data follows immediately after the AX.25 data */
-	memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+		err = -EFAULT;
+		kfree_skb(skb);
+		goto out;
+	}
+
 	skb->nh.raw = skb->data;
 
 	/* Add the PID if one is not supplied by the user in the skb */
