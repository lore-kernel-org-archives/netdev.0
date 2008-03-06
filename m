From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 6/7 net-2.6.26] [TIPC]: Enhancements to message header writing
Date: Thu,  6 Mar 2008 16:34:28 -0500
Message-ID: <1204839269-30593-7-git-send-email-allan.stephens@windriver.com>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55395 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764078AbYCFVu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 16:50:29 -0500
In-Reply-To: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes two enhancements to the routine used to
set bit fields within a TIPC message header:

 1) It now ignores any bits of the new field value that are not
    covered by the mask being used.  (Previously, if the new value
    exceeded the size of the mask the extra bits could corrupt
    other fields in the message header word being updated.)

 2) The code has been optimized to minimize the number of run-time
    endianness conversion operations by leveraging the fact that the
    mask (and, in some cases, the value as well) is constant and the
    necessary conversion can be performed by the compiler.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 88a2ee0..6ad070d 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -70,8 +70,10 @@ static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 				u32 pos, u32 mask, u32 val)
 {
 	val = (val & mask) << pos;
-	m->hdr[w] &= ~htonl(mask << pos);
-	m->hdr[w] |= htonl(val);
+	val = htonl(val);
+	mask = htonl(mask << pos);
+	m->hdr[w] &= ~mask;
+	m->hdr[w] |= val;
 }
 
 /*
-- 
1.5.3.2

