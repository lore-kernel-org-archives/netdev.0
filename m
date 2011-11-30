From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH 1/2] ipv4 : igmp : Delete useless parameter in ip_mc_add1_src()
Date: Thu,  1 Dec 2011 00:21:04 +0800
Message-ID: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
Cc: netdev@vger.kernel.org, Jun Zhao <mypopydev@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:32889 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1K3QWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:22:25 -0500
Received: by iage36 with SMTP id e36so978764iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:22:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need not to used 'delta' flag when add single-source to interface
filter source list.

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv4/igmp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 22c10b5..e6ed796 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1574,7 +1574,7 @@ out_unlock:
  * Add multicast single-source filter to the interface list
  */
 static int ip_mc_add1_src(struct ip_mc_list *pmc, int sfmode,
-	__be32 *psfsrc, int delta)
+	__be32 *psfsrc)
 {
 	struct ip_sf_list *psf, *psf_prev;
 
@@ -1709,7 +1709,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		pmc->sfcount[sfmode]++;
 	err = 0;
 	for (i=0; i<sfcount; i++) {
-		err = ip_mc_add1_src(pmc, sfmode, &psfsrc[i], delta);
+		err = ip_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
 	}
-- 
1.7.2.5
