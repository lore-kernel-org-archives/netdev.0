From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/14] sctp: remove the typedef sctp_sock_state_t
Date: Sat,  5 Aug 2017 19:59:56 +0800
Message-ID: <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
 <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36336 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:01 -0400
In-Reply-To: <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sock_state_t, and
replace with enum sctp_sock_state in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 6 +++---
 include/net/sctp/sctp.h      | 3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 8ce6d32..049868e 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -42,7 +42,7 @@
 
 #include <linux/sctp.h>
 #include <linux/ipv6.h> /* For ipv6hdr. */
-#include <net/tcp_states.h>  /* For TCP states used in sctp_sock_state_t */
+#include <net/tcp_states.h>  /* For TCP states used in enum sctp_sock_state */
 
 /* Value used for stream negotiation. */
 enum { SCTP_MAX_STREAM = 0xffff };
@@ -214,13 +214,13 @@ typedef enum {
  * - A socket in SCTP_SS_ESTABLISHED state indicates that it has a single 
  *   association.
  */
-typedef enum {
+enum sctp_sock_state {
 	SCTP_SS_CLOSED         = TCP_CLOSE,
 	SCTP_SS_LISTENING      = TCP_LISTEN,
 	SCTP_SS_ESTABLISHING   = TCP_SYN_SENT,
 	SCTP_SS_ESTABLISHED    = TCP_ESTABLISHED,
 	SCTP_SS_CLOSING        = TCP_CLOSE_WAIT,
-} sctp_sock_state_t;
+};
 
 /* These functions map various type to printable names.  */
 const char *sctp_cname(const sctp_subtype_t);	/* chunk types */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ca66b03..0022bc7 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -565,7 +565,8 @@ static inline int __sctp_state(const struct sctp_association *asoc,
 
 /* Is the socket in this state? */
 #define sctp_sstate(sk, state) __sctp_sstate((sk), (SCTP_SS_##state))
-static inline int __sctp_sstate(const struct sock *sk, sctp_sock_state_t state)
+static inline int __sctp_sstate(const struct sock *sk,
+				enum sctp_sock_state state)
 {
 	return sk->sk_state == state;
 }
-- 
2.1.0
