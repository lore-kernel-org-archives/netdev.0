From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [WANROUTER] LL_RESERVED_SPACE
Date: Mon, 09 Feb 2004 13:43:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134335.71212303.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: [WANROUTER] Use LL_RESERVED_SPACE() where appricable.

===== net/wanrouter/af_wanpipe.c 1.31 vs edited =====
--- 1.31/net/wanrouter/af_wanpipe.c	Sun Oct  5 15:51:01 2003
+++ edited/net/wanrouter/af_wanpipe.c	Mon Feb  9 12:39:45 2004
@@ -591,14 +591,14 @@
   		return -EMSGSIZE;
 	}
 
-	skb = sock_alloc_send_skb(sk, len+dev->hard_header_len+15, 
+	skb = sock_alloc_send_skb(sk, len + LL_RESERVED_SPACE(dev),
 				msg->msg_flags & MSG_DONTWAIT, &err);
 
 	if (skb==NULL){
 		goto out_unlock;
 	}
 		
-	skb_reserve(skb, (dev->hard_header_len+15)&~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb->nh.raw = skb->data;
 
 	/* Returns -EFAULT on error */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
