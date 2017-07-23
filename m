From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/11] sctp: remove the typedef sctp_heartbeat_chunk_t
Date: Sun, 23 Jul 2017 09:34:35 +0800
Message-ID: <cff8b94db487caa09014f0de9e94e28a13a9e43d.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
 <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
 <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
 <94b6f03745317ab5c57639f2155a5e1503b4dfb3.1500773578.git.lucien.xin@gmail.com>
 <734295f5625300a5328c19e255dfbbf7d393e48f.1500773578.git.lucien.xin@gmail.com>
 <b38e31f3ac26b5aa2f8a6522b002846a03a70118.1500773578.git.lucien.xin@gmail.com>
 <5de5ee9134309f0111da5edd768faf7aaff1c9fc.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34050 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755288AbdGWBgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:36:05 -0400
In-Reply-To: <5de5ee9134309f0111da5edd768faf7aaff1c9fc.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_heartbeat_chunk_t, and
replace with struct sctp_heartbeat_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/sm_statefuns.c | 3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 6e26b86..bfda7c6 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -398,10 +398,10 @@ struct sctp_heartbeathdr {
 	struct sctp_paramhdr info;
 };
 
-typedef struct sctp_heartbeat_chunk {
+struct sctp_heartbeat_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_heartbeathdr hb_hdr;
-} sctp_heartbeat_chunk_t;
+};
 
 
 /* For the abort and shutdown ACK we must carry the init tag in the
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 32ac90b..7bbee08 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1088,7 +1088,8 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the HEARTBEAT chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_heartbeat_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk,
+				     sizeof(struct sctp_heartbeat_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-- 
2.1.0
