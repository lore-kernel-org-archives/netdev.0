From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 1/9] sctp: check parameter value of length in
 ERROR chunk
Date: Wed, 20 Apr 2011 15:25:40 +0800
Message-ID: <4DAE8A74.2060106@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62406 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753484Ab1DTHZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:25:37 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

When an endpoint receives ERROR that parameter value is invalid,
send an ABORT to peer with a Protocol Violation error code.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/sm_statefuns.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c085472..fe2036d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3204,6 +3204,7 @@ sctp_disposition_t sctp_sf_operr_notify(const struct sctp_endpoint *ep,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
+	sctp_errhdr_t *err;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -3212,6 +3213,10 @@ sctp_disposition_t sctp_sf_operr_notify(const struct sctp_endpoint *ep,
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_operr_chunk_t)))
 		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
 						  commands);
+	sctp_walk_errors(err, chunk->chunk_hdr);
+	if ((void *)err != (void *)chunk->chunk_end)
+		return sctp_sf_violation_paramlen(ep, asoc, type, arg,
+						  (void *)err, commands);
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_OPERR,
 			SCTP_CHUNK(chunk));
-- 
1.6.5.2


