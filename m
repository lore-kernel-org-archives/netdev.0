From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/6] qed: Reduce verbosity of unimplemented MFW messages
Date: Thu, 23 Mar 2017 15:50:18 +0200
Message-ID: <1490277020-31208-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46981 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933668AbdCWNup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:45 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Management firmware and driver are meant to be both backward and forward
compatibile with each other.

If a new mangement firmware would work with an older driver,
it's possible that driver would receive indications which are meaningless
to it. That's perfectly acceptible from the firmware part - so no need to
log such messages at default verbosity; That would only serve to confuse
users.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index d1fcd87..ccea0ea 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1114,7 +1114,7 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 			qed_mcp_update_bw(p_hwfn, p_ptt);
 			break;
 		default:
-			DP_NOTICE(p_hwfn, "Unimplemented MFW message %d\n", i);
+			DP_INFO(p_hwfn, "Unimplemented MFW message %d\n", i);
 			rc = -EINVAL;
 		}
 	}
-- 
1.9.3
