From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 24/27] sctp: add rfc6525 section 5.2.6
Date: Sun,  1 Jan 2017 19:20:41 +0800
Message-ID: <19ee2333d24194c0a4b3e724a1a738873ca27445.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
 <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
 <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
 <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
 <3a60ce82edef82f329fe2cc4ac83e9ca21831d8b.1483269426.git.lucien.xin@gmail.com>
 <9be4c65c6bac7df0dbf51328af92727e5606dc5c.1483269426.git.lucien.xin@gmail.com>
 <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
 <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
 <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
 <105630d2f9a54de9c3ce49988452d2b111c71b3d.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35556 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdAALYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:24:04 -0500
In-Reply-To: <105630d2f9a54de9c3ce49988452d2b111c71b3d.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Add Incoming
Streams Request Parameter described in section 5.2.6.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |  4 ++++
 net/sctp/stream.c     | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 5624b52..b8ca767 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -297,6 +297,10 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_addstrm_in(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index b51a037..a2b248b 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -339,3 +339,62 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 out:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
+
+struct sctp_chunk *sctp_process_strreset_addstrm_in(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_addstrm *addstrm = param.v;
+	__u32 result = SCTP_STRRESET_DENIED;
+	__u32 request_seq;
+	__u16 i, nums;
+
+	request_seq = ntohl(addstrm->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ))
+		goto out;
+
+	if (asoc->strreset_outstanding) {
+		result = SCTP_STRRESET_ERR_IN_PROGRESS;
+		goto out;
+	}
+
+	nums = ntohs(addstrm->number_of_streams);
+	if (!nums || nums + asoc->streamoutcnt > SCTP_MAX_STREAM)
+		goto out;
+
+	nums = nums + asoc->streamoutcnt;
+	if (ksize(asoc->streamout) / sizeof(*asoc->streamout) < nums) {
+		struct sctp_stream_out *streamout;
+
+		streamout = kcalloc(nums, sizeof(*streamout), GFP_ATOMIC);
+		if (!streamout)
+			goto out;
+
+		memcpy(streamout, asoc->streamout,
+		       sizeof(*streamout) * asoc->streamoutcnt);
+
+		kfree(asoc->streamout);
+		asoc->streamout = streamout;
+	}
+
+	for (i = asoc->streamoutcnt; i < nums; i++)
+		asoc->streamout[i].state = SCTP_STREAM_OPEN;
+
+	asoc->streamoutcnt = nums;
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_stream_change_event(asoc,
+		0, 0, ntohs(addstrm->number_of_streams), GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_resp(asoc, result, request_seq);
+}
-- 
2.1.0
