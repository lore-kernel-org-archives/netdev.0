From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET] netfilter : xt_time should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 12:30:37 +0100
Message-ID: <47398ADD.2030509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030309040904050102080809"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:3921 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752195AbXKMLao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 06:30:44 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf1908.orange.fr (SMTP Server) with ESMTP id 9A3791C000A7
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 12:30:43 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030309040904050102080809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

It is not correct to assume one can get nsec from a ktime directly by 
using .tv64 field.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------030309040904050102080809
Content-Type: text/plain;
 name="xt_time.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xt_time.patch"

diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index ff44f86..f9c55dc 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -170,7 +170,7 @@ static bool xt_time_match(const struct sk_buff *skb,
 	if (skb->tstamp.tv64 == 0)
 		__net_timestamp((struct sk_buff *)skb);
 
-	stamp = skb->tstamp.tv64;
+	stamp = ktime_to_ns(skb->tstamp);
 	do_div(stamp, NSEC_PER_SEC);
 
 	if (info->flags & XT_TIME_LOCAL_TZ)

--------------030309040904050102080809--


