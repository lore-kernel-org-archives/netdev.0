From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPV6] ADDRCONF: Fix default source address selection without
 CONFIG_IPV6_PRIVACY
Date: Thu, 22 Jun 2006 00:23:41 +0900 (JST)
Message-ID: <20060622.002341.04738770.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:8200 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932170AbWFUPWt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 11:22:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to update hiscore.rule even if we don't enable CONFIG_IPV6_PRIVACY,
because we have more less significant rule; longest match.

I think it is suitable for -stable as well.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1069,6 +1069,9 @@ #ifdef CONFIG_IPV6_PRIVACY
 				if (hiscore.attrs & IPV6_SADDR_SCORE_PRIVACY)
 					continue;
 			}
+#else
+			if (hiscore.rule < 7)
+				hiscore.rule++;
 #endif
 			/* Rule 8: Use longest matching prefix */
 			if (hiscore.rule < 8) {

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
