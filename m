From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 05/14] sctp: remove the typedef sctp_error_t
Date: Thu,  3 Aug 2017 15:42:13 +0800
Message-ID: <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38157 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:23 -0400
In-Reply-To: <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_error_t, and replace
with enum sctp_error in the places where it's using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/sm_statefuns.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 07c12e9..c74ea93 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -457,7 +457,7 @@ struct sctp_operr_chunk {
  *      9              No User Data
  *     10              Cookie Received While Shutting Down
  */
-typedef enum {
+enum sctp_error {
 
 	SCTP_ERROR_NO_ERROR	   = cpu_to_be16(0x00),
 	SCTP_ERROR_INV_STRM	   = cpu_to_be16(0x01),
@@ -512,7 +512,7 @@ typedef enum {
 	 * 0x0105          Unsupported HMAC Identifier
 	 */
 	 SCTP_ERROR_UNSUP_HMAC	= cpu_to_be16(0x0105)
-} sctp_error_t;
+};
 
 
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3b121d2..1d12499 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -528,7 +528,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 			      (struct sctp_init_chunk *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
-		sctp_error_t error = SCTP_ERROR_NO_RESOURCE;
+		enum sctp_error error = SCTP_ERROR_NO_RESOURCE;
 
 		/* This chunk contains fatal error. It is to be discarded.
 		 * Send an ABORT, with causes.  If there are no causes,
-- 
2.1.0
