From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] kill needless addrconf lock in sctp.
Date: Fri, 07 Jan 2005 12:35:19 +0900 (JST)
Message-ID: <20050107.123519.125017441.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com, davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I don't think we really need to obtain this lock here.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

After applying this patch, I think we can stop exporting
addrconf_lock.

===== net/sctp/ipv6.c 1.57 vs edited =====
--- 1.57/net/sctp/ipv6.c	2004-12-28 10:56:34 +09:00
+++ edited/net/sctp/ipv6.c	2005-01-07 12:29:26 +09:00
@@ -319,11 +319,8 @@
 	struct inet6_ifaddr *ifp;
 	struct sctp_sockaddr_entry *addr;
 
-	read_lock(&addrconf_lock);
-	if ((in6_dev = __in6_dev_get(dev)) == NULL) {
-		read_unlock(&addrconf_lock);
+	if ((in6_dev = in6_dev_get(dev)) == NULL)
 		return;
-	}
 
 	read_lock(&in6_dev->lock);
 	for (ifp = in6_dev->addr_list; ifp; ifp = ifp->if_next) {
@@ -340,7 +337,7 @@
 	}
 
 	read_unlock(&in6_dev->lock);
-	read_unlock(&addrconf_lock);
+	in6_dev_put(in6_dev);
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
