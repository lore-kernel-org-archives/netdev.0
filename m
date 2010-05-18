From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 3/3] cxgb4: notify upper drivers if the device is already up when they load
Date: Tue, 18 May 2010 13:07:13 -0700
Message-ID: <1274213233-26309-3-git-send-email-dm@chelsio.com>
References: <1274213233-26309-1-git-send-email-dm@chelsio.com>
 <1274213233-26309-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17226 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab0ERUHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 16:07:15 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4IK7Fkq008165
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 13:07:15 -0700
In-Reply-To: <1274213233-26309-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upper layer drivers aren't notified that a device is ready if their modules
load after the device becomes ready.  Add the missing notification.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 87161ce..58045b0 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2327,6 +2327,9 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 		register_netevent_notifier(&cxgb4_netevent_nb);
 		netevent_registered = true;
 	}
+
+	if (adap->flags & FULL_INIT_DONE)
+		ulds[uld].state_change(handle, CXGB4_STATE_UP);
 }
 
 static void attach_ulds(struct adapter *adap)
-- 
1.5.4

