From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV4: dead lock in error path
Date: Fri, 21 May 2004 17:23:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521.172329.15140532.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

We forgot to release ipip_lock in error path.

--yoshfuji

===== net/ipv4/ipip.c 1.40 vs edited =====
--- 1.40/net/ipv4/ipip.c	Mon Feb 23 14:45:28 2004
+++ edited/net/ipv4/ipip.c	Fri May 21 17:17:28 2004
@@ -479,6 +479,7 @@
 	read_lock(&ipip_lock);
 	if ((tunnel = ipip_tunnel_lookup(iph->saddr, iph->daddr)) != NULL) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+			read_unlock(&ipip_lock);
 			kfree_skb(skb);
 			return 0;
 		}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
