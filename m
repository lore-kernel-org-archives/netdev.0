From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix can_checksum_protocol() arguments swap
Date: Wed, 19 Jan 2011 11:51:36 +0100
Message-ID: <1295434296.3273.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Hans de Bruin <jmdebruin@xmsnet.nl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41909 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab1ASKvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 05:51:41 -0500
Received: by wyb28 with SMTP id 28so762580wyb.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:51:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0363466866d901fbc (net offloading: Convert checksums to use
centrally computed features.) mistakenly swapped can_checksum_protocol()
arguments.

This broke IPv6 on bnx2 for instance, on NIC without TCPv6 checksum
offloads.

Reported-by: Hans de Bruin <jmdebruin@xmsnet.nl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jesse Gross <jesse@nicira.com>
---
I cant believe I spent so much time on this bug.

 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 54277df..cff6d9b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2001,7 +2001,7 @@ static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 
 static int harmonize_features(struct sk_buff *skb, __be16 protocol, int features)
 {
-	if (!can_checksum_protocol(protocol, features)) {
+	if (!can_checksum_protocol(features, protocol)) {
 		features &= ~NETIF_F_ALL_CSUM;
 		features &= ~NETIF_F_SG;
 	} else if (illegal_highdma(skb->dev, skb)) {


