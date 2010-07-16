From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH] ipv6: Make IP6CB(skb)->nhoff 16-bit.
Date: Thu, 15 Jul 2010 22:30:11 -0700 (PDT)
Message-ID: <20100715.223011.58409183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752779Ab0GPF3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:29:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 59EFD24C113
	for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 22:30:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Even with jumbograms I cannot see any way in which we would need
to records a larger than 65535 valued next-header offset.

The maximum extension header length is (256 << 3) == 2048.
There are only a handful of extension headers specified which
we'd even accept (say 5 or 6), therefore the largest next-header
offset we'd ever have to contend with is something less than
say 16k.

Therefore make it a u16 instead of a u32.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
Can anyone find any holes in this?  I want to do this so we
can legitimately rip ndisc_nodetype out of struct sk_buff
and stick it into the IP6CB where it belongs.  Currently
there isn't enough space, but with this change there will
be.

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 940e215..ab9e9e8 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -246,7 +246,7 @@ struct inet6_skb_parm {
 	__u16			srcrt;
 	__u16			dst1;
 	__u16			lastopt;
-	__u32			nhoff;
+	__u16			nhoff;
 	__u16			flags;
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	__u16			dsthao;
