From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/9] netfilter: xt_LED: don't output error message redundantly
Date: Thu, 31 Jul 2014 21:27:04 +0200
Message-ID: <1406834828-8500-6-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

The function led_trigger_register() will only return -EEXIST when
error arises.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LED.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 993de2b..f14bcf2 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -133,9 +133,7 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 
 	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
-		pr_warning("led_trigger_register() failed\n");
-		if (err == -EEXIST)
-			pr_warning("Trigger name is already in use.\n");
+		pr_err("Trigger name is already in use.\n");
 		goto exit_alloc;
 	}
 
-- 
1.7.10.4

