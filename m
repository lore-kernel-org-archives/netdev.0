From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPV6]: Fix tclass setting for raw sockets.
Date: Sat, 02 Sep 2006 03:50:49 +0900 (JST)
Message-ID: <20060902.035049.89154713.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdenis@simphalempin.com,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:18191 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750759AbWIASs4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 14:48:56 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Following patch is for linux-2.6.
I think it is appropriate to push this to -stable.

--- 
[IPV6]: Fix tclass setting for raw sockets.

np->cork.tclass is used only in cork'ed context.
Otherwise, np->tclass should be used.

Bug#7096 reported by Remi Denis-Courmont <rdenis@simphalempin.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
--- 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 3d6e9a3..356a8a7 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -401,7 +401,7 @@ void icmpv6_send(struct sk_buff *skb, in
 	if (hlimit < 0)
 		hlimit = ipv6_get_hoplimit(dst->dev);
 
-	tclass = np->cork.tclass;
+	tclass = np->tclass;
 	if (tclass < 0)
 		tclass = 0;
 
@@ -497,7 +497,7 @@ static void icmpv6_echo_reply(struct sk_
 	if (hlimit < 0)
 		hlimit = ipv6_get_hoplimit(dst->dev);
 
-	tclass = np->cork.tclass;
+	tclass = np->tclass;
 	if (tclass < 0)
 		tclass = 0;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d57e61c..15b862d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -781,7 +781,7 @@ static int rawv6_sendmsg(struct kiocb *i
 	}
 
 	if (tclass < 0) {
-		tclass = np->cork.tclass;
+		tclass = np->tclass;
 		if (tclass < 0)
 			tclass = 0;
 	}

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
