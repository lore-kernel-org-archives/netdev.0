From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] sctp: sctp_sendmsg: Don't initialize default_sinfo
Date: Thu, 12 May 2011 12:19:09 -0700
Message-ID: <a4e846ed62d7f9222dc9b09ca00b5356a1eb9b73.1305227620.git.joe@perches.com>
References: <cover.1305227620.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1305227620.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This variable only needs initialization when cmsgs.info
is NULL.

Don't use memset, just initialize every struct member.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sctp/socket.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 33d9ee6..a5d3560 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1496,8 +1496,8 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct sctp_chunk *chunk;
 	union sctp_addr to;
 	struct sockaddr *msg_name = NULL;
-	struct sctp_sndrcvinfo default_sinfo = { 0 };
 	struct sctp_sndrcvinfo *sinfo;
+	struct sctp_sndrcvinfo default_sinfo;
 	struct sctp_initmsg *sinit;
 	sctp_assoc_t associd = 0;
 	sctp_cmsgs_t cmsgs = { NULL };
@@ -1761,10 +1761,13 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		 * some defaults.
 		 */
 		default_sinfo.sinfo_stream = asoc->default_stream;
+		default_sinfo.sinfo_ssn = 0;
 		default_sinfo.sinfo_flags = asoc->default_flags;
 		default_sinfo.sinfo_ppid = asoc->default_ppid;
 		default_sinfo.sinfo_context = asoc->default_context;
 		default_sinfo.sinfo_timetolive = asoc->default_timetolive;
+		default_sinfo.sinfo_tsn = 0;
+		default_sinfo.sinfo_cumtsn = 0;
 		default_sinfo.sinfo_assoc_id = sctp_assoc2id(asoc);
 		sinfo = &default_sinfo;
 	}
-- 
1.7.5.rc3.dirty
