From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: add ds_to_priv
Date: Mon, 28 Apr 2014 11:14:27 -0700
Message-ID: <1398708868-15084-2-git-send-email-f.fainelli@gmail.com>
References: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47244 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819AbaD1TVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:21:48 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1772142pde.22
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:21:48 -0700 (PDT)
In-Reply-To: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA drivers have a trick which consists in allocating "priv_size" more
bytes to account for the DSA driver private context. Add a helper
function to access that private context instead of open-coding it in
drivers with (void *)(ds + 1).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7828ebf99ee1..6efce384451e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -181,6 +181,11 @@ struct dsa_switch_driver {
 void register_switch_driver(struct dsa_switch_driver *type);
 void unregister_switch_driver(struct dsa_switch_driver *type);
 
+static inline void *ds_to_priv(struct dsa_switch *ds)
+{
+	return (void *)(ds + 1);
+}
+
 /*
  * The original DSA tag format and some other tag formats have no
  * ethertype, which means that we need to add a little hack to the
-- 
1.9.1
