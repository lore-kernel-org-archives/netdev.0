From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 1/3] sctp: Fix the SNMP number of SCTP_MIB_CURRESTAB
Date: Thu,  9 Oct 2008 09:29:33 -0400
Message-ID: <1223558975-1550-3-git-send-email-vladislav.yasevich@hp.com>
References: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:16812 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758522AbYJIN3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 09:29:39 -0400
In-Reply-To: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

RFC3873 defined SCTP_MIB_CURRESTAB:
  sctpCurrEstab OBJECT-TYPE
    SYNTAX         Gauge32
    MAX-ACCESS     read-only
    STATUS         current
    DESCRIPTION
         "The number of associations for which the current state is
         either ESTABLISHED, SHUTDOWN-RECEIVED or SHUTDOWN-PENDING."
    REFERENCE
         "Section 4 in RFC2960 covers the SCTP   Association state
         diagram."

If the T4 RTO timer expires many times(timeout), the association will enter
CLOSED state, so we should dec the number of SCTP_MIB_CURRESTAB, not inc the
number of SCTP_MIB_CURRESTAB.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ea3a34c..1588d06 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5436,7 +5436,7 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
 		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
 				SCTP_PERR(SCTP_ERROR_NO_ERROR));
 		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
-		SCTP_INC_STATS(SCTP_MIB_CURRESTAB);
+		SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
 		return SCTP_DISPOSITION_ABORT;
 	}
 
-- 
1.5.3.5

