From: Jun Zhao <mypopydev@gmail.com>
Subject: [patch v2 1/1] fix error handle in ip_mc_add_src()
Date: Tue, 22 Nov 2011 00:05:16 +0800
Message-ID: <1321891516.14281.62.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52006 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab1KUQGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 11:06:07 -0500
Received: by iage36 with SMTP id e36so7456569iag.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 08:06:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from: Jun Zhao <mypopydev@gmail.com>

When add sources to interface failure, need to roll back the sfcount[MODE] 
to before state. We need to match it corresponding. 

Acked-by: David L Stevens <dlstevens@us.ibm.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..b2ca095 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
        if (err) {
                int j;
 
-               pmc->sfcount[sfmode]--;
+               if (!delta)
+                       pmc->sfcount[sfmode]--;
                for (j=0; j<i; j++)
                        (void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
        } else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
