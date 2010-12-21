From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] bnx2x: remove bogus check
Date: Tue, 21 Dec 2010 10:04:02 +0300
Message-ID: <20101221070401.GF1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49213 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab0LUHET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 02:04:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dereferenced params on the line before so it's too late to check if
params is NULL.  In fact, params can never be NULL and strict_cos is
either 0 or 1 so that part of the check is bogus too.  Let's remove it.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 97cbee2..43b0de2 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -354,9 +354,6 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	struct bnx2x *bp = params->bp;
 	u32 val	= 0;
 
-	if ((1 < strict_cos) && (NULL == params))
-		return -EINVAL;
-
 	DP(NETIF_MSG_LINK, "ETS enabled strict configuration\n");
 	/**
 	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
