From: Jun Zhao <mypopydev@gmail.com>
Subject: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 23:05:46 +0800
Message-ID: <1321887946.14281.27.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57254 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab1KUPKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 10:10:39 -0500
Received: by ywt32 with SMTP id 32so4773810ywt.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 07:10:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When add sources to interface failure, need to roll back the sfcount[MODE] 
to before state. We need to match it corresponding. 

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..276719a 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	if (err) {
 		int j;
 
-		pmc->sfcount[sfmode]--;
+		if(!delta)
+			pmc->sfcount[sfmode]--;
 		for (j=0; j<i; j++)
 			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
