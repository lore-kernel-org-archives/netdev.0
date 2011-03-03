From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: do not mark chunk abandoned if peer has no PRSCTP capable
Date: Thu, 03 Mar 2011 12:20:51 +0800
Message-ID: <4D6F1723.5030909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757807Ab1CCEUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 23:20:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chunk is marked abandoned if the chunk is expires, and it not be
retransmited even if the peer has no PRSCTP capable, but the peer
will still wait for retransmit it to update CTSN.
This patch disable mark chunk abandoned if peer has no PRSCTP
capable.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/chunk.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 6c85564..0d4832d 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -347,6 +347,9 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 {
 	struct sctp_datamsg *msg = chunk->msg;
 
+	if (!chunk->asoc->peer.prsctp_capable)
+		return 0;
+
 	if (!msg->can_abandon)
 		return 0;
 
-- 
1.6.5.2


