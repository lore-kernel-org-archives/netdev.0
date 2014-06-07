From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 RESEND 3/4] macvlan: don't set the same mac address for non-passthru mode
Date: Sat, 7 Jun 2014 15:45:42 +0800
Message-ID: <1402127143-6456-4-git-send-email-dingtianhong@huawei.com>
References: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:32052 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbaFGHqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 03:46:23 -0400
In-Reply-To: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan should have the same mac address only for passthru mode,
so the underlying device couldn't set a new address if it is in use
by macvlan for non-passthru mode, otherwise it will break the work
mechanism.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 67485ab..b6a0065 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1206,8 +1206,12 @@ static int macvlan_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_CHANGEADDR:
-		if (!port->passthru)
+		if (!port->passthru) {
+			if (macvlan_hash_lookup(port, dev->dev_addr))
+				return NOTIFY_BAD;
+
 			return NOTIFY_DONE;
+		}
 
 		vlan = list_first_entry_or_null(&port->vlans,
 						struct macvlan_dev,
-- 
1.8.0
