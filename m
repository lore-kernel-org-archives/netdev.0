From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] cnic: Return error code in cnic_cm_close()
 if unsuccessful.
Date: Tue, 15 Jun 2010 11:57:00 -0700
Message-ID: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1447 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757976Ab0FOSyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 14:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that bnx2i can handle the error condition immediately and not have to
wait for timeout.

Signed-off-by: Michael Chan <mchan@broadcom.com.
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 908d89a..b20e11c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3026,6 +3026,8 @@ static int cnic_cm_close(struct cnic_sock *csk)
 	if (cnic_close_prep(csk)) {
 		csk->state = L4_KCQE_OPCODE_VALUE_CLOSE_COMP;
 		return cnic_cm_close_req(csk);
+	} else {
+		return -EALREADY;
 	}
 	return 0;
 }
-- 
1.6.4.GIT


