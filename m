From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: missing xfrm_loock() in icmpv6_{send,echo_reply}()
Date: Wed, 15 Sep 2004 09:04:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915.090424.59114323.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

net/ipv6/icmp.c was not converted in xfrm_lookup() extraction patch.
This patch converts it; adding the missing call to xfrm_lookup in
icmpv6_{send,echo_reply}().

Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Thanks.

===== net/ipv6/icmp.c 1.58 vs edited =====
--- 1.58/net/ipv6/icmp.c	2004-08-24 06:29:43 +09:00
+++ edited/net/ipv6/icmp.c	2004-09-15 08:53:05 +09:00
@@ -372,6 +372,8 @@
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		goto out_dst_release;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -458,6 +460,8 @@
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		goto out_dst_release;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -489,6 +493,7 @@
 out_put: 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
+out_dst_release:
 	dst_release(dst);
 out: 
 	icmpv6_xmit_unlock();


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
