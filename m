From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] devlink: fix potential memort leak
Date: Sun,  4 Jun 2017 20:49:52 +0800
Message-ID: <1496580592-13659-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must free allocated skb when genlmsg_put() return fails.

Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/core/devlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index b0b87a2..70b69c6 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1680,8 +1680,10 @@ static int devlink_dpipe_tables_fill(struct genl_info *info,
 
 	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
 			  &devlink_nl_family, NLM_F_MULTI, cmd);
-	if (!hdr)
+	if (!hdr) {
+		nlmsg_free(skb);
 		return -EMSGSIZE;
+	}
 
 	if (devlink_nl_put_handle(skb, devlink))
 		goto nla_put_failure;
-- 
1.8.3.1
