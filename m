From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/11] sctp: remove the typedef sctp_abort_chunk_t
Date: Sun, 23 Jul 2017 09:34:36 +0800
Message-ID: <e9d3e79325d75c9283d4d02944d6300bd9b8ac67.1500773578.git.lucien.xin@gmail.com>
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
 <cff8b94db487caa09014f0de9e94e28a13a9e43d.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34071 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752207AbdGWBgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:36:13 -0400
In-Reply-To: <cff8b94db487caa09014f0de9e94e28a13a9e43d.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_abort_chunk_t, and
replace with struct sctp_abort_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/sm_statefuns.c | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index bfda7c6..ba00716 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -408,9 +408,9 @@ struct sctp_heartbeat_chunk {
  * common header. Just the common header is all that is needed with a
  * chunk descriptor.
  */
-typedef struct sctp_abort_chunk {
+struct sctp_abort_chunk {
 	struct sctp_chunkhdr uh;
-} sctp_abort_chunk_t;
+};
 
 
 /* For the graceful shutdown we must carry the tag (in common header)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7bbee08..dc0c2c4 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2164,7 +2164,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
 	 * as we do not know its true length.  So, to be safe, discard the
 	 * packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_abort_chunk)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* ADD-IP: Special case for ABORT chunks
@@ -2206,7 +2206,7 @@ sctp_disposition_t sctp_sf_shutdown_sent_abort(struct net *net,
 	 * as we do not know its true length.  So, to be safe, discard the
 	 * packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_abort_chunk)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* ADD-IP: Special case for ABORT chunks
@@ -2470,7 +2470,7 @@ sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
 	 * as we do not know its true length.  So, to be safe, discard the
 	 * packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_abort_chunk)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* ADD-IP: Special case for ABORT chunks
@@ -2546,7 +2546,7 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 	 * as we do not know its true length.  So, to be safe, discard the
 	 * packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_abort_chunk)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* See if we have an error cause code in the chunk.  */
-- 
2.1.0
