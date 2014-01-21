From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] dlm: use {lock|release}_sock instead, sctp_{lock|release}_sock
Date: Tue, 21 Jan 2014 16:33:23 +0800
Message-ID: <52DE30D3.4070906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <ccaulfie@redhat.com>, <teigland@redhat.com>,
	<cluster-devel@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:47489 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbaAUJcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:32:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we remove the macros sctp_{lock|release}_sock in sctp.h, so change the use
in dlm as well.

This is a followup to ("sctp: remove macros sctp_{lock|release}_sock").

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 fs/dlm/lowcomms.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index d90909e..ce53dff 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -713,11 +713,11 @@ static void process_sctp_notification(struct connection *con,
 				return;
 
 			/* Peel off a new sock */
-			sctp_lock_sock(con->sock->sk);
+			lock_sock(con->sock->sk);
 			ret = sctp_do_peeloff(con->sock->sk,
 				sn->sn_assoc_change.sac_assoc_id,
 				&new_con->sock);
-			sctp_release_sock(con->sock->sk);
+			release_sock(con->sock->sk);
 			if (ret < 0) {
 				log_print("Can't peel off a socket for "
 					  "connection %d to node %d: err=%d",
-- 
1.7.12
