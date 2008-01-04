From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/3] [SCTP]: Add back the code that accounted for FORWARD_TSN parameter in INIT.
Date: Fri,  4 Jan 2008 14:45:46 -0500
Message-ID: <1199475946-11103-4-git-send-email-vladislav.yasevich@hp.com>
References: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13688 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbYADTob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 14:44:31 -0500
In-Reply-To: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some recent changes completely removed accounting for the FORWARD_TSN
parameter length in the INIT and INIT-ACK chunk.  This is wrong and
should be restored.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ed7c9e3..3cc629d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -210,6 +210,9 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	chunksize = sizeof(init) + addrs_len + SCTP_SAT_LEN(num_types);
 	chunksize += sizeof(ecap_param);
 
+	if (sctp_prsctp_enable)
+		chunksize += sizeof(prsctp_param);
+
 	/* ADDIP: Section 4.2.7:
 	 *  An implementation supporting this extension [ADDIP] MUST list
 	 *  the ASCONF,the ASCONF-ACK, and the AUTH  chunks in its INIT and
@@ -369,6 +372,9 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	if (asoc->peer.ecn_capable)
 		chunksize += sizeof(ecap_param);
 
+	if (sctp_prsctp_enable)
+		chunksize += sizeof(prsctp_param);
+
 	if (sctp_addip_enable) {
 		extensions[num_ext] = SCTP_CID_ASCONF;
 		extensions[num_ext+1] = SCTP_CID_ASCONF_ACK;
-- 
1.5.3.5

