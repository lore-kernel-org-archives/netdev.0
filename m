From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 21/25] wimax: checking ERR_PTR vs null
Date: Fri, 14 May 2010 14:45:20 -0700
Message-ID: <d3e56c0ad8a2dab7ffd6179b64f00702149e5c9a.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Dan Carpenter <error27@gmail.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:30552 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932558Ab0ENVtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:19 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

stch_skb is allocated with wimax_gnl_re_state_change_alloc().  That
function returns ERR_PTRs on failure and doesn't return NULL.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
 net/wimax/stack.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 1ed65db..62b1a66 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -315,7 +315,7 @@ void __wimax_state_change(struct wimax_dev *wimax_dev, enum wimax_st new_state)
 		BUG();
 	}
 	__wimax_state_set(wimax_dev, new_state);
-	if (stch_skb)
+	if (!IS_ERR(stch_skb))
 		wimax_gnl_re_state_change_send(wimax_dev, stch_skb, header);
 out:
 	d_fnend(3, dev, "(wimax_dev %p new_state %u [old %u]) = void\n",
-- 
1.6.6.1

