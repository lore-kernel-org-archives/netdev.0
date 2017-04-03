From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net] flow dissector: correct size of storage for ARP
Date: Mon,  3 Apr 2017 15:42:58 -0400
Message-ID: <1491248578-12014-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:35235 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdDCTnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 15:43:05 -0400
Received: by mail-it0-f46.google.com with SMTP id y18so53035967itc.0
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 12:43:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last argument to __skb_header_pointer() should be a buffer large
enough to store struct arphdr. This can be a pointer to a struct arphdr
structure. The code was previously using a pointer to a pointer to
struct arphdr.

By my counting the storage available both before and after is 8 bytes on
x86_64.

Fixes: 55733350e5e8 ("flow disector: ARP support")
Reported-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---

Dave,

this problem is present in both net, since v4.11-rc1 and net-next.
However, the code has refactored in net-next. I expect this will result
in a conflict. Let me know if you would like me to post a version for
net-next too.
---
 net/core/flow_dissector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c35aae13c8d2..d98d4998213d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -390,7 +390,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			unsigned char ar_tip[4];
 		} *arp_eth, _arp_eth;
 		const struct arphdr *arp;
-		struct arphdr *_arp;
+		struct arphdr _arp;
 
 		arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
 					   hlen, &_arp);
-- 
2.7.0.rc3.207.g0ac5344
