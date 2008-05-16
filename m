From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] [SCTP] Fix a type cast bug
Date: Fri, 16 May 2008 16:49:18 +0800
Message-ID: <482D4A8E.4090903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: vladislav <vladislav.yasevich@hp.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57610 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750845AbYEPIvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 04:51:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,

event_arg can never be the type of "struct sctp_chunk *" 
if the event_type is SCTP_EVENT_T_OTHER. This fix
prevents from potential kernel crash by some misuse.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/sctp/sm_sideeffect.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index a4763fd..1b4bae9 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1072,7 +1072,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 	struct sctp_sackhdr sackh;
 	int local_cork = 0;
 
-	if (SCTP_EVENT_T_TIMEOUT != event_type)
+	if (SCTP_EVENT_T_TIMEOUT != event_type &&
+	    SCTP_EVENT_T_OTHER != event_type)
 		chunk = (struct sctp_chunk *) event_arg;
 
 	/* Note:  This whole file is a huge candidate for rework.
-- 
1.5.3

-- 
Regards
Gui Jianfeng

