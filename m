From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: fix a possible dst leakage in ndisc_send_redirect()
Date: Tue, 03 Feb 2004 16:27:54 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203.162754.96958174.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: fix a dst leakage in error path in ndisc_send_redirect().

Thanks.

===== net/ipv6/ndisc.c 1.64 vs edited =====
--- 1.64/net/ipv6/ndisc.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/ndisc.c	Tue Feb  3 16:18:36 2004
@@ -1365,6 +1365,7 @@
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK1("ndisc_send_redirect: alloc_skb failed\n");
+		dst_release(dst);
 		return;
 	}
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
