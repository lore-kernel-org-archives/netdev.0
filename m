From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6]: Fix a branch prediction
Date: Sat, 16 Apr 2005 09:57:13 +0900 (JST)
Message-ID: <20050416.095713.110297063.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tgohad@mvista.com, yoshfuji@linux-ipv6.or
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Tushar Gohad <tgohad@mvista.com>

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/addrconf.c 1.135 vs edited =====
--- 1.135/net/ipv6/addrconf.c	2005-03-31 09:34:56 +09:00
+++ edited/net/ipv6/addrconf.c	2005-04-16 09:48:15 +09:00
@@ -571,7 +571,7 @@
 out2:
 	read_unlock_bh(&addrconf_lock);
 
-	if (unlikely(err == 0))
+	if (likely(err == 0))
 		notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
 	else {
 		kfree(ifa);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
Homepage: http://www.yoshifuji.org/~hideaki/
GPG FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
