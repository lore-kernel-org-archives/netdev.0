From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.20] [IPV6]: Repair IPv6 Fragments
Date: Tue, 05 Dec 2006 18:28:28 +0900 (JST)
Message-ID: <20061205.182828.110151638.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kozakai@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39248 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937409AbWLEJ2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 04:28:15 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

The commit "[IPV6]: Use kmemdup" (commit-id:
af879cc704372ef762584e916129d19ffb39e844) broke IPv6 fragments.

Bug was spotted by Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e05ecbb..e9212c7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -624,13 +624,13 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		skb_shinfo(skb)->frag_list = NULL;
 		/* BUILD HEADER */
 
+		*prevhdr = NEXTHDR_FRAGMENT;
 		tmp_hdr = kmemdup(skb->nh.raw, hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
 			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
 
-		*prevhdr = NEXTHDR_FRAGMENT;
 		__skb_pull(skb, hlen);
 		fh = (struct frag_hdr*)__skb_push(skb, sizeof(struct frag_hdr));
 		skb->nh.raw = __skb_push(skb, hlen);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
