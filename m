From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Fix BUG When Received Unknown Protocol
Date: Thu, 21 Nov 2002 01:32:03 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021121.013203.100868154.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru.ee.t.u-tokyo.ac.jp,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Since 2.5.43, kernel panics by executing BUG() when
received unknown protocol in IPv6 packet. 
This is because ip6_input_finish() try to kfree_skb() 
while icmpv6_param_prob() has already kfree_skb()'ed the skb.

Thanks.

Patch-Name: Fix BUG When Received Unknown Protocol
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Index: net/ipv6/ip6_input.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux25/net/ipv6/ip6_input.c,v
retrieving revision 1.1.1.3
retrieving revision 1.2
diff -u -r1.1.1.3 -r1.2
--- net/ipv6/ip6_input.c	31 Oct 2002 03:58:27 -0000	1.1.1.3
+++ net/ipv6/ip6_input.c	21 Nov 2002 05:30:59 -0000	1.2
@@ -182,9 +182,10 @@
 		if (!raw_sk) {
 			IP6_INC_STATS_BH(Ip6InUnknownProtos);
 			icmpv6_param_prob(skb, ICMPV6_UNK_NEXTHDR, nhoff);
-		} else
+		} else {
 			IP6_INC_STATS_BH(Ip6InDelivers);
-		kfree_skb(skb);
+			kfree_skb(skb);
+		}
 	}
 
 	return 0;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
