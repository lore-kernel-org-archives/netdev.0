From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 4/4] rose check error on memcpy_fromiovec
Date: Mon, 8 Dec 2003 20:27:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208202729.F30587@build.pdx.osdl.net>
References: <20031208202302.C30587@build.pdx.osdl.net> <20031208202414.D30587@build.pdx.osdl.net> <20031208202517.E30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031208202517.E30587@build.pdx.osdl.net>; from chrisw@osdl.org on Mon, Dec 08, 2003 at 08:25:17PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

===== net/rose/af_rose.c 1.33 vs edited =====
--- 1.33/net/rose/af_rose.c	Tue Sep  9 11:22:56 2003
+++ edited/net/rose/af_rose.c	Mon Dec  8 16:58:33 2003
@@ -1079,7 +1079,11 @@
 
 	asmptr = skb->h.raw = skb_put(skb, len);
 
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	err = memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
 
 	/*
 	 *	If the Q BIT Include socket option is in force, the first
