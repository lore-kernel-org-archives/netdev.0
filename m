From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 05/14] sctp: remove the typedef sctp_transport_cmd_t
Date: Sat,  5 Aug 2017 19:59:55 +0800
Message-ID: <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32901 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:00:53 -0400
In-Reply-To: <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_transport_cmd_t, and
replace with enum sctp_transport_cmd in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 4 ++--
 include/net/sctp/structs.h   | 7 ++++---
 net/sctp/associola.c         | 2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 0503bb7..8ce6d32 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -320,11 +320,11 @@ typedef enum {
 } sctp_xmit_t;
 
 /* These are the commands for manipulating transports.  */
-typedef enum {
+enum sctp_transport_cmd {
 	SCTP_TRANSPORT_UP,
 	SCTP_TRANSPORT_DOWN,
 	SCTP_TRANSPORT_PF,
-} sctp_transport_cmd_t;
+};
 
 /* These are the address scopes defined mainly for IPv4 addresses
  * based on draft of SCTP IPv4 scoping <draft-stewart-tsvwg-sctp-ipv4-00.txt>.
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index d771d41..d098d1c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1947,9 +1947,10 @@ void sctp_assoc_del_peer(struct sctp_association *asoc,
 			 const union sctp_addr *addr);
 void sctp_assoc_rm_peer(struct sctp_association *asoc,
 			 struct sctp_transport *peer);
-void sctp_assoc_control_transport(struct sctp_association *,
-				  struct sctp_transport *,
-				  sctp_transport_cmd_t, sctp_sn_error_t);
+void sctp_assoc_control_transport(struct sctp_association *asoc,
+				  struct sctp_transport *transport,
+				  enum sctp_transport_cmd command,
+				  sctp_sn_error_t error);
 struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *, __u32);
 struct sctp_transport *sctp_assoc_is_match(struct sctp_association *,
 					   struct net *,
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 4c1f1bb..b53efed 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -796,7 +796,7 @@ void sctp_assoc_del_nonprimary_peers(struct sctp_association *asoc,
  */
 void sctp_assoc_control_transport(struct sctp_association *asoc,
 				  struct sctp_transport *transport,
-				  sctp_transport_cmd_t command,
+				  enum sctp_transport_cmd command,
 				  sctp_sn_error_t error)
 {
 	struct sctp_ulpevent *event;
-- 
2.1.0
