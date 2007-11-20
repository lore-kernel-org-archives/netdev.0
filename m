From: "Jonas Danielsson" <the.sator@gmail.com>
Subject: [PATCH][v2] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Tue, 20 Nov 2007 17:28:22 +0100
Message-ID: <cac0ab7d0711200828n3548fadn48cce2837ed6a7c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:49016 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbXKTQ2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 11:28:23 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2434090wah
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 08:28:22 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix arp reply when received arp probe with sender ip 0.

Send arp reply with target ip address 0.0.0.0 and target hardware address
set to hardware address of requester. Previously sent reply with target
ip address and target hardware address set to same as source fields.


Signed-off-by: Jonas Danielsson <the.sator@gmail.com>
Acked-by: Alexey Kuznetov <kuznet@ms2.inr.ac.ru>
---
arp.c |    3 ++-
1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -828,7 +828,8 @@ static int arp_process(struct sk_buff *skb)
                if (arp->ar_op == htons(ARPOP_REQUEST) &&
                    inet_addr_type(tip) == RTN_LOCAL &&
                    !arp_ignore(in_dev,dev,sip,tip))
-
arp_send(ARPOP_REPLY,ETH_P_ARP,tip,dev,tip,sha,dev->dev_addr,dev->dev_addr);
+                       arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
+                                dev->dev_addr, sha);
                goto out;
        }
