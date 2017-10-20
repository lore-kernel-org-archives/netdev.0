From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] tun: do not arm flow_gc_timer in tun_flow_init()
Date: Fri, 20 Oct 2017 11:29:57 -0700
Message-ID: <20171020182957.32729-4-edumazet@google.com>
References: <20171020182957.32729-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:53784 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752369AbdJTSaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:30:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id t188so12195107pfd.10
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:30:07 -0700 (PDT)
In-Reply-To: <20171020182957.32729-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timer is properly armed on demand from tun_flow_update(),
so there is no need to arm it at tun init.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 995887de5a98283382a631bcb8dfd874a4037ed3..2a2d058cdd403594e3f89c9a491ada17e3063506 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1197,8 +1197,6 @@ static void tun_flow_init(struct tun_struct *tun)
 
 	tun->ageing_time = TUN_FLOW_EXPIRE;
 	setup_timer(&tun->flow_gc_timer, tun_flow_cleanup, (unsigned long)tun);
-	mod_timer(&tun->flow_gc_timer,
-		  round_jiffies_up(jiffies + tun->ageing_time));
 }
 
 static void tun_flow_uninit(struct tun_struct *tun)
-- 
2.15.0.rc0.271.g36b669edcc-goog
