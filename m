From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: IDLETIMER: fix race condition when destroy the target
Date: Mon,  9 May 2016 21:52:02 +0200
Message-ID: <1462823523-6682-3-git-send-email-pablo@netfilter.org>
References: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

Workqueue maybe still in running while we destroy the IDLETIMER target,
thus cause a use after free error, add cancel_work_sync() to avoid such
situation.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_IDLETIMER.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index 29d2c31..daf45da 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -236,6 +236,7 @@ static void idletimer_tg_destroy(const struct xt_tgdtor_param *par)
 
 		list_del(&info->timer->entry);
 		del_timer_sync(&info->timer->timer);
+		cancel_work_sync(&info->timer->work);
 		sysfs_remove_file(idletimer_tg_kobj, &info->timer->attr.attr);
 		kfree(info->timer->attr.attr.name);
 		kfree(info->timer);
-- 
2.1.4

