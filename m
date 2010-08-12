From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: dont filter cached routes on iproute_get
Date: Thu, 12 Aug 2010 11:05:19 +0200
Message-ID: <20100812090519.GA13769@babylon>
References: <20100808193304.GA15380@amd64.fatal.se>
 <AANLkTim4h7rTJuF7UWAE-p_4NGkrwksUjoK6m2x5BubG@mail.gmail.com>
 <1281297165.4116.19.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Comolli <fabio.comolli@gmail.com>, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-101.dex002.intermedia.net ([64.78.19.88]:39262 "EHLO
	DHOST002-101.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753000Ab0HLJUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 05:20:37 -0400
Content-Disposition: inline
In-Reply-To: <1281297165.4116.19.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute_get will return cloned routes for IPv4
and cloned as well non-cloned routes for IPv6.

Therefore RTM_F_CLONED flag should not be checked
for iproute_get routes. Check in print_route will
always fail because valid values are 0 and 1.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/iproute.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 711576e..b43933c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1286,6 +1286,7 @@ int iproute_get(int argc, char **argv)
 	memset(&req, 0, sizeof(req));
 
 	iproute_reset_filter();
+	filter.cloned = 2;
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
 	req.n.nlmsg_flags = NLM_F_REQUEST;
-- 
1.7.0.4

