From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp_diag should dump sctp socket type
Date: Thu, 26 May 2016 03:14:28 +0800
Message-ID: <53ebf63eb6de080418949f52d0d3556af2a371e1.1464203668.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	phil@nwl.cc
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35859 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbcEYTOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:14:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we cannot distinguish that one sk is a udp or sctp style when
we use ss to dump sctp_info. it's necessary to dump it as well.

For sctp_diag, ss support is not officially available, thus there
are no official users of this yet, so we can add this field in the
middle of sctp_info without breaking user API.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 1 +
 net/sctp/socket.c    | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index dacb5e7..3a406af 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -761,6 +761,7 @@ struct sctp_info {
 	__u32	sctpi_s_autoclose;
 	__u32	sctpi_s_adaptation_ind;
 	__u32	sctpi_s_pd_point;
+	__u32	sctpi_s_type;
 	__u8	sctpi_s_nodelay;
 	__u8	sctpi_s_disable_fragments;
 	__u8	sctpi_s_v4mapped;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 777d032..ebb8e41 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4216,6 +4216,7 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 		info->sctpi_s_autoclose = sp->autoclose;
 		info->sctpi_s_adaptation_ind = sp->adaptation_ind;
 		info->sctpi_s_pd_point = sp->pd_point;
+		info->sctpi_s_type = sp->type;
 		info->sctpi_s_nodelay = sp->nodelay;
 		info->sctpi_s_disable_fragments = sp->disable_fragments;
 		info->sctpi_s_v4mapped = sp->v4mapped;
-- 
2.1.0
