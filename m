From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/14] sctp: remove the typedef sctp_cmsgs_t
Date: Fri, 11 Aug 2017 10:23:48 +0800
Message-ID: <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36810 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752269AbdHKCYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:24:37 -0400
In-Reply-To: <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cmsgs_t, and
replace with struct sctp_cmsgs in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 4 ++--
 net/sctp/socket.c          | 9 +++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 937187f..e171d3a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1985,11 +1985,11 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc);
 
 /* A convenience structure to parse out SCTP specific CMSGs. */
-typedef struct sctp_cmsgs {
+struct sctp_cmsgs {
 	struct sctp_initmsg *init;
 	struct sctp_sndrcvinfo *srinfo;
 	struct sctp_sndinfo *sinfo;
-} sctp_cmsgs_t;
+};
 
 /* Structure for tracking memory objects */
 typedef struct {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a1e2113..0181906 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1593,7 +1593,8 @@ static int sctp_error(struct sock *sk, int flags, int err)
  */
 /* BUG:  We do not implement the equivalent of sk_stream_wait_memory(). */
 
-static int sctp_msghdr_parse(const struct msghdr *, sctp_cmsgs_t *);
+static int sctp_msghdr_parse(const struct msghdr *msg,
+			     struct sctp_cmsgs *cmsgs);
 
 static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 {
@@ -1609,7 +1610,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	struct sctp_sndrcvinfo *sinfo;
 	struct sctp_initmsg *sinit;
 	sctp_assoc_t associd = 0;
-	sctp_cmsgs_t cmsgs = { NULL };
+	struct sctp_cmsgs cmsgs = { NULL };
 	enum sctp_scope scope;
 	bool fill_sinfo_ttl = false, wait_connect = false;
 	struct sctp_datamsg *datamsg;
@@ -7445,10 +7446,10 @@ static int sctp_autobind(struct sock *sk)
  * msg_control
  * points here
  */
-static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
+static int sctp_msghdr_parse(const struct msghdr *msg, struct sctp_cmsgs *cmsgs)
 {
-	struct cmsghdr *cmsg;
 	struct msghdr *my_msg = (struct msghdr *)msg;
+	struct cmsghdr *cmsg;
 
 	for_each_cmsghdr(cmsg, my_msg) {
 		if (!CMSG_OK(my_msg, cmsg))
-- 
2.1.0
