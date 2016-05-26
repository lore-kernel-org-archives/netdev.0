From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH net] ieee802154: fix logic error in
 ieee802154_llsec_parse_dev_addr
Date: Thu, 26 May 2016 21:07:42 +0800
Message-ID: <7c36848d-28b5-87cc-f998-53cc2428a0a6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: aar@pengutronix.de, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33979 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbcEZNHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 09:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a logic error to avoid potential null pointer dereference.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
 net/ieee802154/nl802154.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index ca207db..116187b 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -1289,8 +1289,8 @@ ieee802154_llsec_parse_dev_addr(struct nlattr *nla,
 				     nl802154_dev_addr_policy))
 		return -EINVAL;
 
-	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] &&
-	    !attrs[NL802154_DEV_ADDR_ATTR_MODE] &&
+	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] ||
+	    !attrs[NL802154_DEV_ADDR_ATTR_MODE] ||
 	    !(attrs[NL802154_DEV_ADDR_ATTR_SHORT] ||
 	      attrs[NL802154_DEV_ADDR_ATTR_EXTENDED]))
 		return -EINVAL;
-- 
1.9.1
