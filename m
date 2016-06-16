From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net, cls: also reject deleting all filters when TCA_KIND present
Date: Thu, 16 Jun 2016 23:19:29 +0200
Message-ID: <bbc75e17b5625ef0c41737dcb2b8a5a6faf990d5.1466111210.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58367 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbcFPVTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 17:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we check for RTM_DELTFILTER, we should also reject the request
for deleting all filters under a given parent when TCA_KIND attribute
is present. If present, it's currently just ignored but there's also
no point to let it pass in the first place either since this doesn't
have any meaning with wild-card removal.

Fixes: ea7f8277f907 ("net, cls: allow for deleting all filters for given parent")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index cca1ef5..843a716 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -169,7 +169,7 @@ replay:
 	if (prio == 0) {
 		switch (n->nlmsg_type) {
 		case RTM_DELTFILTER:
-			if (protocol || t->tcm_handle)
+			if (protocol || t->tcm_handle || tca[TCA_KIND])
 				return -ENOENT;
 			break;
 		case RTM_NEWTFILTER:
-- 
1.9.3
