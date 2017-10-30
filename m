From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH iproute2 2/3] xfrm_policy: Do not attempt to deleteall a
 socket policy
Date: Mon, 30 Oct 2017 19:11:45 +0100
Message-ID: <70068e8e-a6c2-2c3a-67aa-6a432619d372@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58720 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752800AbdJ3SNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 14:13:09 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id 79C29201D4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:08 +0100 (CET)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id ytMpVYY5JpS9 for <netdev@vger.kernel.org>;
        Mon, 30 Oct 2017 19:13:08 +0100 (CET)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id 13CF2201D3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:08 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket polices are added to a socket using setsockopt(2). They cannot be
deleted by iproute2. The attempt to delete them causes an error
(EINVAL).
To avoid this unnecessary error message all socket policies are skipped
in xfrm_policy_keep.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 ip/xfrm_policy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 7d2139e..e2fa771 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -735,6 +735,10 @@ static int xfrm_policy_keep(const struct sockaddr_nl *who,
 	if (!xfrm_policy_filter_match(xpinfo, ptype))
 		return 0;
 
+	/* can't delete socket policies */
+	if (xpinfo->dir >= XFRM_POLICY_MAX)
+		return 0;
+
 	if (xb->offset + NLMSG_LENGTH(sizeof(*xpid)) > xb->size)
 		return 0;
 
-- 
2.6.4
