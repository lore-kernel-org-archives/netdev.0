From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/9] ipv6: drop unneeded goto
Date: Thu, 28 May 2015 23:02:17 +0200
Message-ID: <1432846944-7122-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1432846944-7122-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:51325
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932105AbbE1VLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:11:40 -0400
In-Reply-To: <1432846944-7122-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Delete jump to a label on the next line, when that label is not
used elsewhere.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier l;
@@

-if (...) goto l;
-l:
// </smpl>

Also remove the unnecessary ret variable.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv6/raw.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 484a5c1..ca4700c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1327,13 +1327,7 @@ static struct inet_protosw rawv6_protosw = {
 
 int __init rawv6_init(void)
 {
-	int ret;
-
-	ret = inet6_register_protosw(&rawv6_protosw);
-	if (ret)
-		goto out;
-out:
-	return ret;
+	return inet6_register_protosw(&rawv6_protosw);
 }
 
 void rawv6_exit(void)
