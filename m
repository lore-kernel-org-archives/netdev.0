From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 3/4] netrom check error on memcpy_fromiovec (resend)
Date: Fri, 16 Jan 2004 14:27:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116142723.U19023@osdlab.pdx.osdl.net>
References: <20040116142502.B19034@osdlab.pdx.osdl.net> <20040116142614.T19023@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040116142614.T19023@osdlab.pdx.osdl.net>; from chrisw@osdl.org on Fri, Jan 16, 2004 at 02:26:14PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

 net/netrom/af_netrom.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

===== net/netrom/af_netrom.c 1.43 vs edited =====
--- 1.43/net/netrom/af_netrom.c	Fri Jan  9 01:56:08 2004
+++ edited/net/netrom/af_netrom.c	Fri Jan 16 14:17:01 2004
@@ -1101,7 +1101,12 @@
 	SOCK_DEBUG(sk, "NET/ROM: Appending user data\n");
 
 	/* User data follows immediately after the NET/ROM transport header */
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (memcpy_fromiovec(asmptr, msg->msg_iov, len)) {
+		kfree_skb(skb);
+		err = -EFAULT;
+		goto out;
+	}
+
 	SOCK_DEBUG(sk, "NET/ROM: Transmitting buffer\n");
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
