From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 3/4] netrom check error on memcpy_fromiovec
Date: Mon, 8 Dec 2003 20:25:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208202517.E30587@build.pdx.osdl.net>
References: <20031208202302.C30587@build.pdx.osdl.net> <20031208202414.D30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031208202414.D30587@build.pdx.osdl.net>; from chrisw@osdl.org on Mon, Dec 08, 2003 at 08:24:14PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

===== net/netrom/af_netrom.c 1.40 vs edited =====
--- 1.40/net/netrom/af_netrom.c	Sun Sep 21 18:17:31 2003
+++ edited/net/netrom/af_netrom.c	Fri Dec  5 16:45:14 2003
@@ -1094,7 +1094,12 @@
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
