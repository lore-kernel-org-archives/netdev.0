From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/6] net: dsa: Move ports assignment closer to error checking
Date: Mon, 27 Jun 2016 17:52:41 -0700
Message-ID: <1467075163-15890-5-git-send-email-f.fainelli@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34835 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbcF1Awv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:52:51 -0400
Received: by mail-oi0-f66.google.com with SMTP id d132so260244oig.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:51 -0700 (PDT)
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the assignment of ports in _dsa_register_switch() closer to where
it is checked, no functional change. Re-order declarations to be
preserve the inverted christmas tree style.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index bdde5d217326..a565bd919aa3 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -598,8 +598,8 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
+	struct device_node *ports;
 	u32 tree, index;
 	int err;
 
@@ -607,6 +607,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	if (err)
 		return err;
 
+	ports = dsa_get_ports(ds, np);
 	if (IS_ERR(ports))
 		return PTR_ERR(ports);
 
-- 
2.7.4
