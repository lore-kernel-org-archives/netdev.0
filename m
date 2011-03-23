From: Holger Hans Peter Freyther <holger@freyther.de>
Subject: [PATCH] sctp: Make some local functions static
Date: Wed, 23 Mar 2011 11:48:07 +0100
Message-ID: <4D89CFE7.4050907@freyther.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gandharva.secretlabs.de ([78.46.147.237]:58657 "EHLO
	gandharva.secretlabs.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303Ab1CWK5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 06:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sparse proposed to mark these functions as static as they are
only accessed locally. This patch is doing that.

Signed-off-by: Holger Hans Peter Freyther <zecke@selfish.org>
Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/probe.c         |   10 +++++-----
 net/sctp/sm_make_chunk.c |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index bc6cd75..4616548 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -122,11 +122,11 @@ static const struct file_operations sctpprobe_fops = {
 	.llseek = noop_llseek,
 };
 -sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
-				     void *arg,
-				     sctp_cmd_seq_t *commands)
+static sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const sctp_subtype_t type,
+					    void *arg,
+					    sctp_cmd_seq_t *commands)
 {
 	struct sctp_transport *sp;
 	static __u32 lcwnd = 0;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..a8c0798 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -132,8 +132,8 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16
cause_code,
  * abort chunk.  Differs from sctp_init_cause in that it won't oops
  * if there isn't enough space in the op error chunk
  */
-int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
-		      size_t paylen)
+static int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
+				 size_t paylen)
 {
 	sctp_errhdr_t err;
 	__u16 len;
-- 
1.7.4

