From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH net-next 5/5] irda: Fix heap memory corruption in iriap.c
Date: Mon, 11 Oct 2010 02:25:02 +0200
Message-ID: <37f9fc452d138dfc4da2ee1ce5ae85094efc3606.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11562 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab0JKA0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:26:14 -0400
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While parsing the GetValuebyClass command frame, we could potentially write
passed the skb->data pointer.

Cc: stable@kernel.org
Reported-by: Ilja Van Sprundel <ivansprundel@ioactive.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/iriap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index fce364c..5b743bd 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -502,7 +502,8 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 		IRDA_DEBUG(4, "%s(), strlen=%d\n", __func__, value_len);
 
 		/* Make sure the string is null-terminated */
-		fp[n+value_len] = 0x00;
+		if (n + value_len < skb->len)
+			fp[n + value_len] = 0x00;
 		IRDA_DEBUG(4, "Got string %s\n", fp+n);
 
 		/* Will truncate to IAS_MAX_STRING bytes */
-- 
1.7.1

