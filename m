From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPSEC: typo in xfrm_sk_clone_policy()
Date: Wed, 12 Mar 2003 16:17:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030312.161749.123173528.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I think following patch fixes a typo in xfrm_sk_clone_policy()
which results in infinite loop if sk->policy[0] or sk->policy[1] is true.

Patch is for 2.5.64.

Thanks.

Index: include/net/xfrm.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/xfrm.h,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 xfrm.h
--- include/net/xfrm.h	16 Feb 2003 04:09:06 -0000	1.1.1.7
+++ include/net/xfrm.h	12 Mar 2003 07:06:20 -0000
@@ -335,7 +335,7 @@
 static inline int xfrm_sk_clone_policy(struct sock *sk)
 {
 	if (unlikely(sk->policy[0] || sk->policy[1]))
-		return xfrm_sk_clone_policy(sk);
+		return __xfrm_sk_clone_policy(sk);
 	return 0;
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
