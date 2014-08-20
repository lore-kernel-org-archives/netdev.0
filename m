From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe
Date: Wed, 20 Aug 2014 17:31:43 +0800
Message-ID: <1408527103-22772-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1408527103-22772-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: dborkman@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, vyasevich@gmail.com, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, davem@davemloft.net,
	zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408527103-22772-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the transport has always been in state SCTP_UNCONFIRMED, it
therefore wasn't active before and hasn't been used before, and it
always has been, so it is unnecessary to bug the user with a 
notification.

Reported-by: Deepak Khandelwal <khandelwal.deepak.1987@gmail.com>  
Suggested-by: Vlad Yasevich <vyasevich@gmail.com> 
Suggested-by: Michael Tuexen <tuexen@fh-muenster.de>
Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/sctp/associola.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 9de23a2..2e23f6b 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -813,6 +813,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 		else {
 			dst_release(transport->dst);
 			transport->dst = NULL;
+			ulp_notify = false;
 		}
 
 		spc_state = SCTP_ADDR_UNREACHABLE;
-- 
1.9.1
