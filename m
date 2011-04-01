From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 1/2] sctp: fix auth_hmacs field's length of struct sctp_cookie
Date: Fri, 01 Apr 2011 17:38:54 +0800
Message-ID: <4D959D2E.40605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: lksctp <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56923 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755284Ab1DAJig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 05:38:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

auth_hmacs field of struct sctp_cookie is used for store
Requested HMAC Algorithm Parameter, and each HMAC Identifier
is 2 bytes, so the length should be:
  SCTP_AUTH_NUM_HMACS * sizeof(__u16) + 2

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cc9185c..0f6e60a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -422,7 +422,7 @@ struct sctp_cookie {
 	__u32 adaptation_ind;
 
 	__u8 auth_random[sizeof(sctp_paramhdr_t) + SCTP_AUTH_RANDOM_LENGTH];
-	__u8 auth_hmacs[SCTP_AUTH_NUM_HMACS + 2];
+	__u8 auth_hmacs[SCTP_AUTH_NUM_HMACS * sizeof(__u16) + 2];
 	__u8 auth_chunks[sizeof(sctp_paramhdr_t) + SCTP_AUTH_MAX_CHUNKS];
 
 	/* This is a shim for my peer's INIT packet, followed by
-- 
1.6.5.2


