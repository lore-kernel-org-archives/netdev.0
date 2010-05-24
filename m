From: Yoichi Yuasa <yuasa@linux-mips.org>
Subject: net/dccp: expansion of error code size
Date: Mon, 24 May 2010 15:45:08 +0900
Message-ID: <20100524154508.10a40589.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yuasa@linux-mips.org, linux-mips <linux-mips@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:32777 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab0EXIh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 04:37:27 -0400
Received: by pvg4 with SMTP id 4so694302pvg.19
        for <netdev@vger.kernel.org>; Mon, 24 May 2010 01:37:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because MIPS's EDQUOT value is 1133(0x46d).
It's larger than u8.

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
---
 net/dccp/input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 58f7bc1..6beb6a7 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -124,9 +124,9 @@ static int dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
 	return queued;
 }
 
-static u8 dccp_reset_code_convert(const u8 code)
+static u16 dccp_reset_code_convert(const u8 code)
 {
-	const u8 error_code[] = {
+	const u16 error_code[] = {
 	[DCCP_RESET_CODE_CLOSED]	     = 0,	/* normal termination */
 	[DCCP_RESET_CODE_UNSPECIFIED]	     = 0,	/* nothing known */
 	[DCCP_RESET_CODE_ABORTED]	     = ECONNRESET,
@@ -148,7 +148,7 @@ static u8 dccp_reset_code_convert(const u8 code)
 
 static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
 {
-	u8 err = dccp_reset_code_convert(dccp_hdr_reset(skb)->dccph_reset_code);
+	u16 err = dccp_reset_code_convert(dccp_hdr_reset(skb)->dccph_reset_code);
 
 	sk->sk_err = err;
 
-- 
1.7.1

