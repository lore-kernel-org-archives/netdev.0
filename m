From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [XFRM] xfrm_alloc_spi() always selected minspi
Date: Sat, 14 Jun 2003 11:16:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614.111619.37286104.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

net/xfrm/xfrm_state.c:xfrm_alloc_spi() always selected minspi because of typo.
Bug was originally introduced in ChangeSet 1.889.1.182
(net/xfrm/xfrm_state.c@1.11); it is 4 months old...

Here's the fix.

Thanks in advance.

Index: linux-2.5/net/xfrm/xfrm_state.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/xfrm/xfrm_state.c,v
retrieving revision 1.9
diff -u -p -r1.9 xfrm_state.c
--- linux-2.5/net/xfrm/xfrm_state.c	7 Jun 2003 00:22:34 -0000	1.9
+++ linux-2.5/net/xfrm/xfrm_state.c	14 Jun 2003 00:54:18 -0000
@@ -513,7 +513,7 @@ xfrm_alloc_spi(struct xfrm_state *x, u32
 		maxspi = ntohl(maxspi);
 		for (h=0; h<maxspi-minspi+1; h++) {
 			spi = minspi + net_random()%(maxspi-minspi+1);
-			x0 = xfrm_state_lookup(&x->id.daddr, minspi, x->id.proto, x->props.family);
+			x0 = xfrm_state_lookup(&x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL)
 				break;
 			xfrm_state_put(x0);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
