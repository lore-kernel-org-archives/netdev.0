From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 8/8] net: dsa: free distributed switch tree pointer in dsa_remove
Date: Mon, 12 Jan 2015 13:57:46 -0800
Message-ID: <1421099866-3184-9-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:37031 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbALV6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:58:03 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so34447209pab.2
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:58:02 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We allocate a "dst" pointer in dsa_probe(), but we are not freeing it
accordingly in dsa_remove(), do that to avoid leaking it.

Fixes: 91da11f870f00 ("net: Distributed Switch Architecture protocol support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 008a1a58cf0c..b511713b8885 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -776,6 +776,7 @@ static int dsa_remove(struct platform_device *pdev)
 	wmb();
 
 	dsa_of_remove(pdev);
+	kfree(dst);
 
 	return 0;
 }
-- 
2.1.0
