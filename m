From: Wei Yongjun <weiyongjun1@huawei.com>
Subject: [PATCH net-next] sctp: fix error return code in sctp_send_add_streams()
Date: Tue, 31 Oct 2017 13:28:16 +0000
Message-ID: <1509456496-93944-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <linux-sctp@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:9486 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751876AbdJaNZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 09:25:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to returnerror code -ENOMEM from the sctp_make_strreset_addstrm()
error handling case instead of 0. 'retval' can be overwritten to 0 after
call sctp_stream_alloc_out().

Fixes: e090abd0d81c ("sctp: factor out stream->out allocation")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/sctp/stream.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 03764fc..b8c8cab 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -393,7 +393,7 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 {
 	struct sctp_stream *stream = &asoc->stream;
 	struct sctp_chunk *chunk = NULL;
-	int retval = -ENOMEM;
+	int retval;
 	__u32 outcnt, incnt;
 	__u16 out, in;
 
@@ -425,8 +425,10 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 	}
 
 	chunk = sctp_make_strreset_addstrm(asoc, out, in);
-	if (!chunk)
+	if (!chunk) {
+		retval = -ENOMEM;
 		goto out;
+	}
 
 	asoc->strreset_chunk = chunk;
 	sctp_chunk_hold(asoc->strreset_chunk);
