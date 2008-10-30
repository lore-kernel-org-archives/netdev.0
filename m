From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 1/3] cipso: unsigned buf_len cannot be negative
Date: Thu, 30 Oct 2008 13:10:19 -0400
Message-ID: <20081030171019.11396.40616.stgit@flek.lan>
References: <20081030170736.11396.46099.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:47402 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757377AbYJ3RKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 13:10:21 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g5t0007.atlanta.hp.com (Postfix) with ESMTP id 049C7141F4
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:10:21 +0000 (UTC)
In-Reply-To: <20081030170736.11396.46099.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roel kluin <roel.kluin@gmail.com>

unsigned buf_len cannot be negative

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/ipv4/cipso_ipv4.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 490e035..2e78f6b 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -2063,9 +2063,10 @@ int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 	u32 opt_len;
 	int len_delta;
 
-	buf_len = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
-	if (buf_len < 0)
-		return buf_len;
+	ret_val = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
+	if (ret_val < 0)
+		return ret_val;
+	buf_len = ret_val;
 	opt_len = (buf_len + 3) & ~3;
 
 	/* we overwrite any existing options to ensure that we have enough

