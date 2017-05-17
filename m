From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] sctp: do not inherit ipv6_{mc|ac|fl}_list from parent
Date: Wed, 17 May 2017 07:16:40 -0700
Message-ID: <1495030600.6465.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34930 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdEQOQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 10:16:42 -0400
Received: by mail-pg0-f65.google.com with SMTP id i63so2001540pgd.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 07:16:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

SCTP needs fixes similar to 83eaddab4378 ("ipv6/dccp: do not inherit
ipv6_mc_list from parent"), otherwise bad things can happen.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/sctp/ipv6.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 142b70e959af9142ce35b88749ad2160327c8267..f5b45b8b8b16e6965d24cd79b150828a608c2121 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -677,6 +677,9 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	newnp = inet6_sk(newsk);
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+	newnp->ipv6_mc_list = NULL;
+	newnp->ipv6_ac_list = NULL;
+	newnp->ipv6_fl_list = NULL;
 
 	rcu_read_lock();
 	opt = rcu_dereference(np->opt);
