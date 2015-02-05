From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH] dsa: correctly determine the number of switches in a system
Date: Thu, 5 Feb 2015 14:54:09 +0100
Message-ID: <20150205135409.GB29383@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:48212 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbbBENyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:54:15 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so6416044lbi.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:54:14 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id b6sm977351laa.14.2015.02.05.05.54.13
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Feb 2015 05:54:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of connected switches was sourced from the number of
children to the DSA node, change it to the number of available
children, skipping any disabled switches.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 3731714..2173402 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -603,7 +603,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 
 	pdev->dev.platform_data = pd;
 	pd->netdev = &ethernet_dev->dev;
-	pd->nr_chips = of_get_child_count(np);
+	pd->nr_chips = of_get_available_child_count(np);
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
 		pd->nr_chips = DSA_MAX_SWITCHES;
 
-- 
1.8.4.357.g8d83871.dirty
