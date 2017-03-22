From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] NFC: netlink: Use error code from nfc_activate_target()
Date: Wed, 22 Mar 2017 21:20:58 +0200
Message-ID: <20170322192058.30193-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>,
        linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31561 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934719AbdCVTVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 15:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like a typo to assign a return code to a variable which is not
used. Found due to a compiler warning:

net/nfc/netlink.c: In function ‘nfc_genl_activate_target’:
net/nfc/netlink.c:903:6: warning: variable ‘rc’ set but not used [-Wunused-but-set-variable]
  int rc;
        ^~

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/nfc/netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 03f3d5c7beb8..03be522127ec 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -918,7 +918,7 @@ static int nfc_genl_activate_target(struct sk_buff *skb, struct genl_info *info)
 	rc = nfc_activate_target(dev, target_idx, protocol);
 
 	nfc_put_device(dev);
-	return 0;
+	return rc;
 }
 
 static int nfc_genl_dep_link_up(struct sk_buff *skb, struct genl_info *info)
-- 
2.11.0
