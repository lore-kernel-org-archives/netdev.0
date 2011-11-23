From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH v3] ipv4 : igmp : fix error handle in ip_mc_add_src()
Date: Wed, 23 Nov 2011 11:19:03 +0800
Message-ID: <1322018343-7552-1-git-send-email-mypopydev@gmail.com>
Cc: eric.dumazet@gmail.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, Jun Zhao <mypopydev@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51046 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125Ab1KWDTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 22:19:32 -0500
Received: by ywt32 with SMTP id 32so907350ywt.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 19:19:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from: Jun Zhao <mypopydev@gmail.com>

When add sources to interface failure, need to roll back the sfcount[MODE]
to before state. We need to match it corresponding.

Acked-by: David L Stevens <dlstevens@us.ibm.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv4/igmp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..b2ca095 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	if (err) {
 		int j;
 
-		pmc->sfcount[sfmode]--;
+		if (!delta)
+			pmc->sfcount[sfmode]--;
 		for (j=0; j<i; j++)
 			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
-- 
1.7.2.5
