From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 1/4] ax25 check error on memcpy_fromiovec (resend)
Date: Fri, 16 Jan 2004 14:25:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116142502.B19034@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

 net/ax25/af_ax25.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

===== net/ax25/af_ax25.c 1.36 vs edited =====
--- 1.36/net/ax25/af_ax25.c	Fri Jan  9 01:53:04 2004
+++ edited/net/ax25/af_ax25.c	Fri Jan 16 14:13:54 2004
@@ -1526,7 +1526,12 @@
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
