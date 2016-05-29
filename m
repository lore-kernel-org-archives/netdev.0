From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] sctp: sctp_diag should dump sctp socket type
Date: Sun, 29 May 2016 17:42:13 +0800
Message-ID: <56c3ecedbc132e8501fd7cfbe056525155a1f915.1464514933.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	phil@nwl.cc
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36765 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075AbcE2JmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 05:42:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we cannot distinguish that one sk is a udp or sctp style when
we use ss to dump sctp_info. it's necessary to dump it as well.

For sctp_diag, ss support is not officially available, thus there
are no official users of this yet, so we can add this field in the
middle of sctp_info without breaking user API.

v1->v2:
  - move 'sctpi_s_type' field to the end of struct sctp_info, so
    that it won't cause incompatibility with applications already
    built.
  - add __reserved3 in sctp_info to make sure sctp_info is 8-byte
    alignment.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 2 ++
 net/sctp/socket.c    | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index dacb5e7..de1f643 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -765,6 +765,8 @@ struct sctp_info {
 	__u8	sctpi_s_disable_fragments;
 	__u8	sctpi_s_v4mapped;
 	__u8	sctpi_s_frag_interleave;
+	__u32	sctpi_s_type;
+	__u32	__reserved3;
 };
 
 struct sctp_infox {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 777d032..67154b8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4220,6 +4220,7 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 		info->sctpi_s_disable_fragments = sp->disable_fragments;
 		info->sctpi_s_v4mapped = sp->v4mapped;
 		info->sctpi_s_frag_interleave = sp->frag_interleave;
+		info->sctpi_s_type = sp->type;
 
 		return 0;
 	}
-- 
2.1.0
