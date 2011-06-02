From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH] qlcnic: Fix bug in FW queue dump
Date: Thu,  2 Jun 2011 15:42:21 -0700
Message-ID: <1307054541-11178-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:58833 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752599Ab1FBWtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 18:49:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a change in FW template, a bug was introduced in dump queue entries. This is
fixed by reinitializing queue address before looping for each que dump operation.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index e965661..a5d9fbf 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1406,6 +1406,7 @@ qlcnic_dump_que(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
 
 	for (loop = 0; loop < que->no_ops; loop++) {
 		QLCNIC_WR_DUMP_REG(que->sel_addr, base, que_id);
+		addr = que->read_addr;
 		for (i = 0; i < cnt; i++) {
 			QLCNIC_RD_DUMP_REG(addr, base, &data);
 			*buffer++ = cpu_to_le32(data);
-- 
1.7.4.1

