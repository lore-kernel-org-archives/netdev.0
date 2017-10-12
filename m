From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 1/2] mqprio: Add a new hardware offload type in mqprio
Date: Thu, 12 Oct 2017 10:38:31 +0800
Message-ID: <1507775912-22402-2-git-send-email-linyunsheng@huawei.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <yuvalm@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:7978 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdJLBxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 21:53:20 -0400
In-Reply-To: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a driver supports both dcb and hardware offloaded mqprio, and
user is running mqprio and dcb tool concurrently, the configuration
set by each tool may be conflicted with each other because the dcb
and mqprio may be using the same hardwere offload component and share
the tc system in the network stack.

This patch adds a new offload type to indicate that the underlying
driver offload prio mapping as part of DCB. If the driver would be
incapable of that it would refuse the offload. User would then have
to explicitly request that qdisc offload.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
Suggested-by: Yuval Mintz <yuvalm@mellanox.com>
---
 include/uapi/linux/pkt_sched.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf55..8016027 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -620,6 +620,7 @@ struct tc_drr_stats {
 enum {
 	TC_MQPRIO_HW_OFFLOAD_NONE,	/* no offload requested */
 	TC_MQPRIO_HW_OFFLOAD_TCS,	/* offload TCs, no queue counts */
+	TC_MQPRIO_HW_OFFLOAD_DCB,	/* offload shared by DCB */
 	__TC_MQPRIO_HW_OFFLOAD_MAX
 };
 
-- 
1.9.1
