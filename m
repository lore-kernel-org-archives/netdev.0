From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ieee802154: fix gcc-4.9 warnings
Date: Tue, 12 Sep 2017 12:16:24 +0200
Message-ID: <20170912101636.3811626-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Marcel Holtmann <marcel@holtmann.org>,
        "David S. Miller" <davem@davemloft.net>,
        Markus Elfring <elfring@users.sourceforge.net>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Florian Westphal <fw@strlen.de>,
        Johannes Berg <johannes.berg@intel.com>,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        Colin Ian King <colin.king@canonical.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:61145 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdILKRe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 06:17:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All older compiler versions up to gcc-4.9 produce these
harmless warnings:

drivers/net/ieee802154/ca8210.c: In function 'ca8210_skb_tx':
drivers/net/ieee802154/ca8210.c:1947:9: warning: missing braces around initializer [-Wmissing-braces]

This changes the syntax to something that works on all versions
without warnings.

Fixes: ded845a781a5 ("ieee802154: Add CA8210 IEEE 802.15.4 device driver")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ieee802154/ca8210.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
index 24a1eabbbc9d..e6b8ce81a6c3 100644
--- a/drivers/net/ieee802154/ca8210.c
+++ b/drivers/net/ieee802154/ca8210.c
@@ -1944,7 +1944,7 @@ static int ca8210_skb_tx(
 )
 {
 	int status;
-	struct ieee802154_hdr header = { 0 };
+	struct ieee802154_hdr header = { };
 	struct secspec secspec;
 	unsigned int mac_len;
 
-- 
2.9.0
