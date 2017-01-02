From: Reiter Wolfgang <wr0112358@gmail.com>
Subject: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Tue,  3 Jan 2017 00:34:10 +0100
Message-ID: <20170102233410.4070-1-wr0112358@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Reiter Wolfgang <wr0112358@gmail.com>
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Final nlmsg_len field update must reflect inserted net_dm_drop_point
data.

This patch depends on previous patch:
"drop_monitor: add missing call to genlmsg_end"

Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
---
 net/core/drop_monitor.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index f465bad..ccaaf3e 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -102,7 +102,6 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	}
 	msg = nla_data(nla);
 	memset(msg, 0, al);
-	genlmsg_end(skb, msg_header);
 	goto out;
 
 err:
@@ -112,6 +111,12 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	swap(data->skb, skb);
 	spin_unlock_irqrestore(&data->lock, flags);
 
+	if(skb) {
+		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
+		struct genlmsghdr *gnlh = (struct genlmsghdr *)nlmsg_data(nlh);
+		genlmsg_end(skb, genlmsg_data(gnlh));
+	}
+
 	return skb;
 }
 
-- 
2.9.3
