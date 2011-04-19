From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 4/8] sctp: kill abandoned SCTP_CMD_TRANSMIT command
Date: Tue, 19 Apr 2011 13:12:40 +0800
Message-ID: <4DAD19C8.8010105@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55671 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752167Ab1DSFM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:12:59 -0400
In-Reply-To: <4DAD18AB.3040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

Remove SCTP_CMD_TRANSMIT command as it never be used.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/command.h |    1 -
 net/sctp/sm_sideeffect.c   |    6 ------
 2 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index c01dc99..2b44764 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -73,7 +73,6 @@ typedef enum {
 	SCTP_CMD_INIT_FAILED,   /* High level, do init failure work. */
 	SCTP_CMD_REPORT_DUP,	/* Report a duplicate TSN.  */
 	SCTP_CMD_STRIKE,	/* Mark a strike against a transport.  */
-	SCTP_CMD_TRANSMIT,      /* Transmit the outqueue. */
 	SCTP_CMD_HB_TIMERS_START,    /* Start the heartbeat timers. */
 	SCTP_CMD_HB_TIMER_UPDATE,    /* Update a heartbeat timers.  */
 	SCTP_CMD_HB_TIMERS_STOP,     /* Stop the heartbeat timers.  */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 5f86ee4..3b80fe2 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1415,12 +1415,6 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 					SCTP_RTXR_T3_RTX);
 			break;
 
-		case SCTP_CMD_TRANSMIT:
-			/* Kick start transmission. */
-			error = sctp_outq_uncork(&asoc->outqueue);
-			local_cork = 0;
-			break;
-
 		case SCTP_CMD_ECN_CE:
 			/* Do delayed CE processing.   */
 			sctp_do_ecn_ce_work(asoc, cmd->obj.u32);
-- 
1.6.5.2


