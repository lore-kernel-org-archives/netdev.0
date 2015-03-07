From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/6] mpls: Fix the kzalloc argument order in mpls_rt_alloc
Date: Sat, 07 Mar 2015 16:19:41 -0600
Message-ID: <87y4n84fia.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59378 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbCGWXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:23:18 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


*Blink* I got the argument order wrong to kzalloc and the
code was working properly when tested. *Blink*

Fix that.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 4f265c677eca..59cc32564d50 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -239,7 +239,7 @@ static struct mpls_route *mpls_rt_alloc(size_t alen)
 {
 	struct mpls_route *rt;
 
-	rt = kzalloc(GFP_KERNEL, sizeof(*rt) + alen);
+	rt = kzalloc(sizeof(*rt) + alen, GFP_KERNEL);
 	if (rt)
 		rt->rt_via_alen = alen;
 	return rt;
-- 
2.2.1
