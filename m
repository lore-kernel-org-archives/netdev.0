From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net] netxen: Fix link event handling.
Date: Thu, 6 Nov 2014 07:58:51 -0500
Message-ID: <1415278731-26404-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mkubecek@suse.cz>,
	<Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62247 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751249AbaKFNe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 08:34:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Poll for the link events only if firmware doesn't have capability
  to notify the driver for the link events.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 0b2a1cc..6130375 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2762,7 +2762,8 @@ netxen_fw_poll_work(struct work_struct *work)
 	if (test_bit(__NX_RESETTING, &adapter->state))
 		goto reschedule;
 
-	if (test_bit(__NX_DEV_UP, &adapter->state)) {
+	if (test_bit(__NX_DEV_UP, &adapter->state) &&
+	    !(adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)) {
 		if (!adapter->has_link_events) {
 
 			netxen_nic_handle_phy_intr(adapter);
-- 
1.7.1
