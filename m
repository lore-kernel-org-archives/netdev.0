From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: add NUMA awareness to seg6_hmac_init_algo()
Date: Fri, 20 Jan 2017 08:08:56 -0800
Message-ID: <1484928536.16328.127.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Lebrun <david.lebrun@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36136 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdATQI6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:08:58 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so5712823pfo.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 08:08:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since we allocate per cpu storage, let's also use NUMA hints.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/seg6_hmac.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index 5215e1eba01030dc9345b847eee5ac5ef3bed1b9..b274f1d95e037c93e8e0e6531cfc51709f71297c 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -389,7 +389,8 @@ static int seg6_hmac_init_algo(void)
 			return -ENOMEM;
 
 		for_each_possible_cpu(cpu) {
-			shash = kzalloc(shsize, GFP_KERNEL);
+			shash = kzalloc_node(shsize, GFP_KERNEL,
+					     cpu_to_node(cpu));
 			if (!shash)
 				return -ENOMEM;
 			*per_cpu_ptr(algo->shashs, cpu) = shash;
