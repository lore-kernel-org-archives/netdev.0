From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: reset mac header in dev_start_xmit()
Date: Tue, 05 Feb 2013 22:22:20 -0800
Message-ID: <1360131740.28557.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60870 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab3BFGWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 01:22:23 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so625813pad.7
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 22:22:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On 64 bit arches :

There is a off-by-one error in qdisc_pkt_len_init() because
mac_header is not set in xmit path.

skb_mac_header() returns an out of bound value that was
harmless because hdr_len is an 'unsigned int'

On 32bit arches, the error is abysmal.

This patch is also a prereq for "macvlan: add multicast filter"

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Greear <greearb@candelatech.com>
---
 net/core/dev.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..0b888b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2799,6 +2799,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
+	skb_reset_mac_header(skb);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
