From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6] [IPV6] MIP6: Ensure independence from
 alignment.
Date: Mon, 14 Apr 2008 15:22:45 +0900 (JST)
Message-ID: <20080414.152245.45102039.yoshfuji@linux-ipv6.org>
References: <20080409.004632.68333196.yoshfuji@linux-ipv6.org>
	<20080413.222629.180789339.davem@davemloft.net>
	<20080414.143832.10983998.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33475 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647AbYDNGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:21:01 -0400
In-Reply-To: <20080414.143832.10983998.yoshfuji@wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080414.143832.10983998.yoshfuji@wide.ad.jp> (at Mon, 14 Apr 2008 14:38:32 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp> says:

> > Please just mark the structure with "packed" attribute.
> 
> Sure!

Here it is:

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Apr 2008 14:47:47 +0900
Subject: [PATCH net-2.6] [IPV6]: IPv6 extension header structures need to be packed.

struct ipv6_opt_hdr is the common structure for IPv6 extension
headers, and it is common to increment the pointer to get
the real content.  On the other hand, since the structure
consists only of 1-byte next-header field and 1-byte length
field, size of that structure depends on architecture; 2 or 4.
Add "packed" attribute to get 2.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4aaefc3..134c8e5 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -53,7 +53,7 @@ struct ipv6_opt_hdr {
 	/* 
 	 * TLV encoded option data follows.
 	 */
-};
+} __attribute__ ((packed));	/* required for some archs */
 
 #define ipv6_destopt_hdr ipv6_opt_hdr
 #define ipv6_hopopt_hdr  ipv6_opt_hdr
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
