From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: cls_basic: return from walking on match in basic_get
Date: Thu, 22 Jan 2015 10:58:18 +0100
Message-ID: <1421920699-26556-2-git-send-email-dborkman@redhat.com>
References: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbbAVJ6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:58:51 -0500
In-Reply-To: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as we've found a matching handle in basic_get(), we can
return it. There's no need to continue walking until the end of
a filter chain, since they are unique anyway.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Cc: Thomas Graf <tgraf@suug.ch>
---
 net/sched/cls_basic.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 5aed341..fc399db 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -65,9 +65,12 @@ static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
 	if (head == NULL)
 		return 0UL;
 
-	list_for_each_entry(f, &head->flist, link)
-		if (f->handle == handle)
+	list_for_each_entry(f, &head->flist, link) {
+		if (f->handle == handle) {
 			l = (unsigned long) f;
+			break;
+		}
+	}
 
 	return l;
 }
-- 
1.7.11.7
