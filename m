From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH] net: rtnetlink: fix correct size given to memset
Date: Tue, 11 Feb 2014 15:06:38 +0100
Message-ID: <1392127598-3719-1-git-send-email-fx.lebail@yahoo.com>
To: NETDEV <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:28742 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbaBKOgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 09:36:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Find by cppcheck:
[net/core/rtnetlink.c:1842]: (warning) Using size of pointer linkinfo instead of size of its data.

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---

The diagnosis of cppcheck seems relevant.

 net/core/rtnetlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 048dc8d..9a5dbf1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1839,7 +1839,7 @@ replay:
 		if (err < 0)
 			return err;
 	} else
-		memset(linkinfo, 0, sizeof(linkinfo));
+		memset(linkinfo, 0, sizeof(*linkinfo));
 
 	if (linkinfo[IFLA_INFO_KIND]) {
 		nla_strlcpy(kind, linkinfo[IFLA_INFO_KIND], sizeof(kind));
